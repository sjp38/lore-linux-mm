Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 170F46B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 21:00:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t8so51542594pgs.5
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:00:17 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o6si2268692plh.495.2017.07.20.18.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 18:00:15 -0700 (PDT)
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
 <20170715005554.GA12694@redhat.com>
From: Evgeny Baskakov <ebaskakov@nvidia.com>
Message-ID: <cfba9bfb-5178-bcae-0fa9-ef66e2a871d5@nvidia.com>
Date: Thu, 20 Jul 2017 18:00:08 -0700
MIME-Version: 1.0
In-Reply-To: <20170715005554.GA12694@redhat.com>
Content-Type: multipart/mixed;
	boundary="------------E67503A3980F560ABF583A71"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

--------------E67503A3980F560ABF583A71
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit

On 7/14/17 5:55 PM, Jerome Glisse wrote:

> ...
>
> Cheers,
> JA(C)rA'me

Hi Jerome,

I think I just found a couple of new issues, now related to fork/execve.

1) With a fork() followed by execve(), the child process makes a copy of 
the parent mm_struct object, including the "hmm" pointer. Later on, an 
execve() syscall in the child process frees the old mm_struct, and 
destroys the "hmm" object - which apparently it shouldn't do, because 
the "hmm" object is shared between the parent and child processes:

(gdb) bt
#0  hmm_mm_destroy (mm=0xffff88080757aa40) at mm/hmm.c:134
#1  0xffffffff81058567 in __mmdrop (mm=0xffff88080757aa40) at 
kernel/fork.c:889
#2  0xffffffff8105904f in mmdrop (mm=<optimized out>) at 
./include/linux/sched/mm.h:42
#3  __mmput (mm=<optimized out>) at kernel/fork.c:916
#4  mmput (mm=0xffff88080757aa40) at kernel/fork.c:927
#5  0xffffffff811c5a68 in exec_mmap (mm=<optimized out>) at fs/exec.c:1057
#6  flush_old_exec (bprm=<optimized out>) at fs/exec.c:1284
#7  0xffffffff81214460 in load_elf_binary (bprm=0xffff8808133b1978) at 
fs/binfmt_elf.c:855
#8  0xffffffff811c4fce in search_binary_handler 
(bprm=0xffff88081b40cb78) at fs/exec.c:1625
#9  0xffffffff811c6bbf in exec_binprm (bprm=<optimized out>) at 
fs/exec.c:1667
#10 do_execveat_common (fd=<optimized out>, filename=0xffff88080a101200, 
flags=0x0, argv=..., envp=...) at fs/exec.c:1789
#11 0xffffffff811c6fda in do_execve (__envp=<optimized out>, 
__argv=<optimized out>, filename=<optimized out>) at fs/exec.c:1833
#12 SYSC_execve (envp=<optimized out>, argv=<optimized out>, 
filename=<optimized out>) at fs/exec.c:1914
#13 SyS_execve (filename=<optimized out>, argv=0x7f4e5c2aced0, 
envp=0x7f4e5c2aceb0) at fs/exec.c:1909
#14 0xffffffff810018dd in do_syscall_64 (regs=0xffff88081b40cb78) at 
arch/x86/entry/common.c:284
#15 0xffffffff819e2c06 in entry_SYSCALL_64 () at 
arch/x86/entry/entry_64.S:245

This leads to a sporadic memory corruption in the parent process:

Thread 200 received signal SIGSEGV, Segmentation fault.
[Switching to Thread 3685]
0xffffffff811a3efe in __mmu_notifier_invalidate_range_start 
(mm=0xffff880807579000, start=0x7f4e5c62f000, end=0x7f4e5c66f000) at 
mm/mmu_notifier.c:199
199            if (mn->ops->invalidate_range_start)
(gdb) bt
#0  0xffffffff811a3efe in __mmu_notifier_invalidate_range_start 
(mm=0xffff880807579000, start=0x7f4e5c62f000, end=0x7f4e5c66f000) at 
mm/mmu_notifier.c:199
#1  0xffffffff811ae471 in mmu_notifier_invalidate_range_start 
(end=<optimized out>, start=<optimized out>, mm=<optimized out>) at 
./include/linux/mmu_notifier.h:282
#2  migrate_vma_collect (migrate=0xffffc90003ca3940) at mm/migrate.c:2280
#3  0xffffffff811b04a7 in migrate_vma (ops=<optimized out>, 
vma=0x7f4e5c62f000, start=0x7f4e5c62f000, end=0x7f4e5c66f000, 
src=0xffffc90003ca39d0, dst=0xffffc90003ca39d0, 
private=0xffffc90003ca39c0) at mm/migrate.c:2819
(gdb) p mn->ops
$2 = (const struct mmu_notifier_ops *) 0x6b6b6b6b6b6b6b6b

Please see attached a reproducer (sanity_rmem004_fork.tgz). Use 
"./build.sh; sudo ./kload.sh; ./run.sh" to recreate the issue on your end.


2) A slight modification of the affected application does not use 
fork(). Instead, an execve() call from a parallel thread replaces the 
original process. This is a particularly interesting case, because at 
that point the process is busy migrating pages to/from device.

Here's what happens:

0xffffffff811b9879 in commit_charge (page=<optimized out>, 
lrucare=<optimized out>, memcg=<optimized out>) at mm/memcontrol.c:2060
2060        VM_BUG_ON_PAGE(page->mem_cgroup, page);
(gdb) bt
#0  0xffffffff811b9879 in commit_charge (page=<optimized out>, 
lrucare=<optimized out>, memcg=<optimized out>) at mm/memcontrol.c:2060
#1  0xffffffff811b93d6 in commit_charge (lrucare=<optimized out>, 
memcg=<optimized out>, page=<optimized out>) at 
./include/linux/page-flags.h:149
#2  mem_cgroup_commit_charge (page=0xffff88081b68cb70, 
memcg=0xffff88081b051548, lrucare=<optimized out>, compound=<optimized 
out>) at mm/memcontrol.c:5468
#3  0xffffffff811b10d4 in migrate_vma_insert_page (migrate=<optimized 
out>, dst=<optimized out>, src=<optimized out>, page=<optimized out>, 
addr=<optimized out>) at mm/migrate.c:2605
#4  migrate_vma_pages (migrate=<optimized out>) at mm/migrate.c:2647
#5  migrate_vma (ops=<optimized out>, vma=<optimized out>, 
start=<optimized out>, end=<optimized out>, src=<optimized out>, 
dst=<optimized out>, private=0xffffc900037439c0) at mm/migrate.c:2844


Please find another reproducer attached (sanity_rmem004_execve.tgz) for 
this issue.

Thanks!

-- 
Evgeny Baskakov
NVIDIA


--------------E67503A3980F560ABF583A71
Content-Type: application/x-gzip; name="sanity_rmem004_execve.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="sanity_rmem004_execve.tgz"

H4sIAIBJcVkAA+097XLbOJLzd/QUiDNOKEe2JcVx6qw4s95ETnQbyy7Zvmwuk2LRIiRxLJFa
knKsnfG9z/2/N9gXu24AJAEQlOTYSeZu2FWxJHw00I1GoxtoIJHje/HcDid0Uq/v2PSa9q/o
9g/3CvV6/fmzZ4R97vLPenOHfwogjaeNpzvNnZ1nz5+ReuP5093mD+TZ/XbDDLModkLoCr0a
Un9+4USXzmVwlS8HxQaDBXgEHenn/xGIjON/MfPG7lY0up82lo1/4+luMv713Z0mqTcbUPIH
Ur+f5hfDn3z8h/0+2RySzeOnZPO9Mx6Tzc4W/Bt7/uyaqMKx1SejycSOaRTbg9CZ0M9BeAmJ
m4FWkGxO41FIHbfyvakrYRmY579pnL+8DZgPuzs7RfO/udusN7X5/3SnsVPO/28B2xsVskFe
BdN56A1HMWmCNiY96pK3Tkw6fn8LsrHE2ciLyDQMhiAQBL4OQkpJFAziz05IW2QezEjf8UlI
XS+KQ+9iFlPixcTx3e0gRASTwPUGc0yb+S4NSTyiJKbhJCLBgP140z0nb6hPQ2dMTmYXY69P
3nl96keUOBFimGJiNIK+XcxZjUPsw6noAzkMALETe4HfItSD/JBc0TCC36QJbSAGrCRw1kgQ
EgtohJ6HJJhivSp0d07GTpxVLSI/o9Ilns8Qj4IpUDQClEDjZw9U6QUls4gOZuMaooDC5H3n
7O3x+Rk56H4g7w96vYPu2YcWFI5HAeTSK8pReZPp2APMQFfo+PFcdP+o3Xv1Fqoc/LXzrnP2
ASk47Jx126en5PC4Rw7IyUHvrPPq/N1Bj5yc906OT9tbhJxS7BZFBAtYPABkkwDY6NLY8cZR
QvjBDPoWRnvk3//13+G//mcC4wSDABVe/DpkX/4CQw5Eb/WDyUuosF156NKB51NiQ2v26fF5
71W7Unno+f3xzIVqDtQJ463RSykt9iZUTaFh6Adq0qDvx2M1KYpdL8gn+XEubexd6Gmh5w/V
tJkPo+pq5Wj862RqqhtpifNoezJx/HxqPJ9SQ2FQKHo/IdUL+jqVYjE1IM6xbVFz86gP6ztm
ZDlrBkU/WqukYzikcey5VpVY1tRz7bgqsFinH05tnlmtZsWPzt+dgYT32gev26/to86b3sFZ
m9QL8vEDMrPcg79D2lnvA2nsZqkH7zpvutZ1jTjYC+u6Sp7AvCWbpFGtkkfE+i/Lghz2E3qC
TAWpBhEgNtJGr73YDi7JPqm3kkwYT/tiNpAKUP8qzZ35kTf0YfJNnSG1I++fVKmsZY+8QZzP
Gwf+kBeYwHrSSrsFgjPrx8yK6sfXZGOIHy2p12Ok+CrwXFbGg6XZZmg8fxBYmF6t/FYhAN6A
WGkHq4QnIoQ0noV+i/2+YX9lOnD4An9g2aev7JODN237tPOf7WpLKocEQcHBIJLxA3ulQkgU
lAHOKxRXsxp8PFqVm5S2lChkeI4UeaxkahAtDJelDFWNbDaqMoUMJUu7USQAK7mzyWSObLZD
OoTpTUNLHwX4k/TFwHXREhTafAlzAOgGuZ/ipOAZnOEoIdB40iq2h3gWtdUfOSHwMx75MPM+
Pm1+AkEo7kPKKq6QVI5U8xIAPJJZpE2GhkAY+VNQZfHASvpRIzh8QZZQrZG1bZdeMZPQnXhh
GIRrMk8GyBJY+nwJx7Hde/2+VyN1URD7nRR+AalSbweiA6B4QedDY/1gNnaJH8QMKXKDsDEk
bujBokys9aj6i79WS1kn2jCSLo9QgTTgiLCxSyUUs0H1eAsHbxxENKEpxw7sAGBU9QGiAbUz
oKHtX8xB6cr4eQbZ4J9JK6LnPHHzpY8SEZEXLxTlw2Q+h0hujX62HT/wLZj6UczlboMPlNpD
3q2k8cLecWq1qqxrq0nwA9HOIimw2u0qWY9wsLd4cbL5kqyPXTb0tj2Y+X3brhFOhkCYCUKq
aKqKJAgG7otFhVerEUnRvXyp8JbVEtTvkwmsfEHfEjMkGStJxpOS+6R7/u7dygQmeBnDqwYK
l1OWiEgqfnIiooBk/NAyEn4ow7e9nRbg8x1JnzhTq14jJhGsJbXMcNI7PuNr/e/8+/te56y9
pNLRwYl90uv8B9oPv7NfB93j7oej4/PTJTU3G5negULZsGTU7DOEhwedd+3XySAJfIvHCZkA
MmgaooQ1WcsMHXgoonk1Qx9GSL7JcX8a34X1t+f7FzJ9AccZBX9oduclnU9GS7D7CRgy6Hum
KoIj4F6MJlnVlhmlhSp3o2pp9hI3mrTSTyS7bpObuLqdxesppVqEVDipEzoBC0HrGIxPKj8q
LUqHhbx9CQOgqkY9R7YS6Vj0C+k2Uw0Il5CsrKw5O3UD/S2bu132ReDO5aVaGEE2ZpKNKftM
1kzojdpljxtUqdSxRGg8U7VuoE4JyAS+MTfQYv4BKvUaeXt0ZL8+6vR6xz02qWHV4i1nAk0+
j7wxJRZieASeEfOhcfq1O92zXrWatYlTFErBZGRNas0jY5iFvlFlPVUnzFUwBkZBO4yUjWsc
ZCVto8p7tvnScV3grRgiMdPXPnK2knX3E0z0vXV3j2A5Ur9en9bIlTOe0XSdT9xPnP2H591X
Z53jLmoA237X6bbxG/iFG9cSZbiNYXnosQGDmAQmnYFfLeKB+YnjsS3WcOgSzJ0nTzxNLzH3
Kg4/ep/IAxgMLbdIc+2t77hV8DyACBAiTspHoOUTGYI5u+6CozKlfdwyEgQWKdWMPo+RAf2A
r6pKy2QlWe6ljAug+VJJvdGGUR1na+Na856YJ6rK8lGnq03Ia92CnGuW6/WL+c/Xe3PFNxJW
qTSLTIZ2LbV4DFBomi6spXY1Qp1wi/Jcl6zSLeQhKB32kfBD7OHYMeFfoo+428G3Qk4/tXSD
W9ExReWRoR7fnMh3l/XWngKjxXxLjDyyTSRUGSaulNS5yuYniHD0aU/U3gPRndUSIuCXW8s1
xcqINds8ayuZqOa3hH4ma1MnhEWIjtfIHlmDdcaDCfVP6q4lGr0mk5DvgKbpBN0v5UrajFYI
3iNxEMAy6M855qXkqOa0Ok01lzSbgGLJEpxky5VQSiIpVdhsFYDx43tFmJJpOa7S5AEl3pMn
6nYASo/3aYtpWVDWMyAVdIod6+svmxHwxRMLpsJSSNup/9tuK49XLPR5tJlF84WY+4l7Uhd0
M1kdIOl5PMAGwX+JeAVd6u2gItOrp8bCprmXWfdu0m90HNGljdXlmgoVedHXu55ojT78jan1
KNEduBygh1kT+tsCDc4VefWRbrrUyKOk0upEZCbIAgNExqvUF+YFGiHcBnmQ2CBaQwgwI7TZ
p7fE+oOrJ8O17i6ci1C2xktK1EqE4WRMrRrDwGT9V4UQSNDG1kSMRsnAAaPIBXXC6jKhIk6M
ps74egkV0qS9FSHqt5ts12WxtN1GoyBwMxnEzM6MWZl9maSiAVqv5ijoB37s+TOq1U0k/tfA
8y1Z3B+JtjRmcFFldpzF3ANzlwpsXinbMHo5OaRMny0XQOaOGfAXjVq2KOT6e1shNFPyVeRw
FaKSH4o0Kjvmits18YYhKLplnpcohs6X+JqYWZp7lfpWmagsdKzEiRX6Vgliscu2om9VJGQL
JCs5JVtJuJigq7OgwGEzmvn1BYZ4yvvg1uY4hy8zypW692g5JzIiPu/DftZ2TRfa0WIGyHth
f0wzVF9+79/al7thPCBeaPCrRK1o+H8r2xqRgmAqu+dMDoptVG2QNPW9xETVROlupuoSCzWd
OLIxm1BqKrTQv1hQ5ck+s/+BEiPPqq1FVrMQofswnA2LD5gdUndXZayy6iSw1KZO156CJlmz
Ky5DMr+KbB7Gpntalkw2jyB6VXvbIG4P9gs8OoS822AwcqLUypEaWHeTFpjqypphP6tLVZnW
CwRdptm+XZ4i7dBiNU6p3+BvgUVvmAl3NOrlrCJNl/Tli7Qdwj1rPJVnCIYJqrRbXyqafzBf
5v/xpP4DzGiEbzmdK3pxORJFWOjsWHNpsMjiAAQ1LiyxySYzHw9Z9dPCRQEnmV2pVWaHbivU
VA9pb8o7At8VVo7/v8NdoMXx//XnjfqzXPx/s1nG/38LKOP/y/j/+43/5xJ1mCgOhpn5YZ4/
JKhUQFBwTH0X921oFPFELAa2Cm42BLPhiPGBhWsitksa+nQsQkC3SNvpj3itaMTCRUfOFSWB
D2TM/D4OJQsSSq+rWVUSO5fYvsMECQwyHGMwLJI9LrG6OhFIp/ePGSW4IzGhWAo7yldPhkCu
7fiILlWWQMxsHAtcCQORJtAdvhtxEhFnAKqGBrOIHFHg+ZwcOT6skhPqxzUUHpAvmEojOgYT
F8RxDn89P/Jcmsgwv50nmIJUQFEYuCsYyyRMVhy+OSi0fWQyGjL4GU2dPvIK6iXoeM0tLuQY
/fNZJD2OxN4PNgKizEpHyFkVG3il/RGb5M4lrPogCmAbeH02GRn/YF46hF73R44/pEzeyauT
8wS5Q8YBSL8TeTC48oRLVx/QNOD2TmfhNIBeQA70B5aqsO/Bzysn9JCZ/cClLCpYcEswiFEZ
sK6RaBaKOYrDAuyFIQENBMOehmZgd51xFGCdwXgWjQhOTVQMF7MhmxbblYfeAHTYgNnWZ+3T
M/uwd3DUfn/c+5v9Nr24YMy8pysuhuss+Wsvxusst72PklxpkZKZ9Mnx4DxfusUhnEzSaCqx
yTjRRPh0Fomcgw02l7JgVdxULYKBy8uwyykFZSAPzMzWisH5rRXjwAGfIex6BeoywlhDBbCR
7pktLMX5b9q/VkHet1vGz5tWShnfj+dE4bbe7o6Zy65AL1W9p1j01gr4IkBC7xPhANxOAz5k
HO7aqXgTtH/O8KYiuj+HXkxvf5D0hWdItyX99rTfivg/3FFaC42ypK+ikyzH2D/TcZqGDtZA
nXSwM2JYQYv3KfgEwmKykl1ti6N1h7s0rYqyJP/1/PCw3bO77fcsut2CfoHhb4XVfZOaesiy
ixCcvj3otYsxcMW0GMVh5x3DMChCwpTRw6SEtIqxow2hq5iWQtNH105JzHOailXBp3CDCb+E
Jw2FDxRHY0qnWZSnz7hHfXDdyPaG0aRBe+h7O7ElfDGY938ux4Hz7d5/ed7Q938a9fqzcv/n
W8DDB9sXnr8djSoPKw/JKe48gJvUD71pjB4QysF2SPGDOX/oNinXMdFd4qqIOFNQ7tPQg++A
SrijqJ/Aa6pEc79fCSeTwJXXlQr8hkoXVE4kv//OrvSSBlQgmwOyFU+m9pW9UUnR1kWOfjO1
MnF+DcL9nyzn8yVZ++Wn5v7+L2vSCcgva+Q3dshAfvmpcbNGttE73uY4o2qF9keB0hOGDv3N
n9i3yuTSBwL0Vklf5JN6pT8ahlNCEznK97A/Qh7s7u7ksyrRzA0IuM2iX1BwBtwjv5NhSKfk
sdzkY0hFIh8Len7avXn8JXrYPP+5i3dfMnaL97/E/K8/a9TL97++BZjHP5z596b9Vxj/pv7+
F4x/uf//TYCpnK1tVQxKg+5PA+b5rz/8drc2Fp//NXaePUvf/2rsgC1Ybzabz3fL+f8toDz/
K8//vsb5H2NYdtrXH9H+JefOZ8okJQnQxm2W+QTPbyb8MAy8DuE78ATExs/gwAcZhAHwP06O
YRY/Y7XCE1qG57ayl8HSPZtXx91X571eu3uWhFDZB11+iSYr1Ol2zjoH79IS6SGIcjSSz02z
u/j4Vad9ane63XZPqpdkyEn4ehMkoK5JE9MXnYi1A0xrgJLN9p3EnhPPFtU3sirVdOc+CZ0N
/Jhex3z3f/FbMIZNRJaOfknsubUM5cznAVHphXEsogfe0qHnLy2FDmJy4PDVriwvupyCJ80W
z3HCoeHRnIKbCMqNBY3XG+rvlnKnRboHqVXbJ1YBvip0TdQRkcMP1CIY85Xjqxw3llSzbfTg
7YsgGEPdyRQ0rg2z0o4+O9MkvroQKRvSGmHvhOhxf8bgc9aq1dDLLr2iIeR6m+gdyklgtl++
JLI1hwlH3BTrqhe8c+yrIGYzT4yxC18xClYMZ/E9ALlQ/h5AEWeUewE5FNK9gJUZoMbfimjS
9MEJXLh5ExjJsT5OQkrRAmRJbHXJbsUZmq1pvKgpfdZ7sPQmgN7CajcD7u1WwB1ih8e3Dx42
SKQUJHy3AOFEyRbECCfILZScdbd6r3HCIkZ4JWkxRgyvNFWlJz2yesrPfB1xek3BjhxeffwE
YvcbWWP7veNoDR/2W+PXYchNPoQ5rUv9Ky8MfFG9qDh3HC0Ju2iWfRE4Cuk2RUPLNxrz7zqy
sC7j6SWW8GcTW12DTM/a5V7ZsHmmiClJLx5qmD4a7LhPi5Z1bTUUyWY0uQuNy9/e82rkUrl/
KFkK0jM14GHAkD8CBQGaMJkv6dW+0zP0Hbpv2CQwsU8gNB2hJue7kolZLbhNZ8Ccu4pSwC7v
01b6Ep/MjMVVpOt9ywvH7H1Pb6WikkGBC6KBrhWwmOwkdTVeuS47MdGfyrD0i3C6KGcX4gzm
bbbi5JuvqtdgnIsg1N8kZGPPn94llzD2qn8Daeqw50TVAz+chxAmN0wv5aVMmrCr3j2Uqyx5
tsRcqW+wl+T81EDitpvU2+1t0hkQyrYlTkboEjfQf+dfm+RiHPQvIzRQQnB6ryhzmih3oKf4
1hqeoUm4BIo9cpRO5GTx4/4z+M5bhRfBVpmFCKsZ/7cTb3Ybt5FzAxCKV4c86c09cuhgtC2+
FDsHncderXNimhh1IE1BmJkGfC8nw5LC2YjO0+0aPMCk4XguYZNiQzMEOcPuNk+mCGGRr5Mu
t+AkPtyvTjWrkcYdtFfjzr1Vbs4VqSyNKasudCcHp6ft18uWOZCQ14H/OOb7nDi5xNqDUd/M
6xeWZionoKamIb1ikcip5ooSZFANxCuks4gXRYyDAEOtca8pKaUHRClPWWqXxNieiAP8wS9g
aIG2lkMWucVnMHpwQRSX3jOGb6Uxt5C8hlty2bThG29YYI0zPGeiJLYX1H1kp0ttgR0mvb1Q
040VFBVDFShSsLnWMrVAXuybttqMZbUlSJPVZMUyKkfedyWgmAcGy4VW8LUePHigYCH8pVS2
V2yQ4AWSq7cwDEDsYDYs9BoyMphJzUzo5ehvQRdbw746Tck3JVmJ4lYHJ/U4ANeerkHEi47r
URVfwyDrvIPIqZ/JWrvNXqk4/hsksVlWB4XEdH46iYwz9nuf9JhhUfyHEuJ/hzaW3P97Wn/e
0O//NeuN8vzvW0B5/lee/3218z+8TqaGC6b3tvo0jSe0RsqdOHEMOEnvxFVZP046iaDwa11b
pBOLy2ogd8DnkN9FSwaJtcSvi8UR2Nd4gUzcWkN8vLB82TD3P01g6KJ638s+h27gluD5323Z
uM8ufRWXyF2gMlzD4hmGM0mREf7D55etijaxfqv8mNzT+fFH/vyylMB8Yel3sosvJfXzSQWX
e1z5psf3aDixIRY37UtItjdIm4sEjrd2IZLLFv7nRngSkNyaTAREEg56xSRD/q+udEfvxx/t
zvH7nvX47WNwd6/rdeOdCnZmYcTBXurXkTSMSBj7zViE/avjaRrxpA/pSeH+hcJcxvyXUEIJ
JZRQQgkllFBCCSWUUEIJJZRQQgkllFBCCSWUUEIJJZRQQgkllFBCCSWUUEIJJXw3+F8fkMj+
AKAAAA==
--------------E67503A3980F560ABF583A71
Content-Type: application/x-gzip; name="sanity_rmem004_fork.tgz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="sanity_rmem004_fork.tgz"

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
u8H/AnckeZoAoAAA
--------------E67503A3980F560ABF583A71--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
