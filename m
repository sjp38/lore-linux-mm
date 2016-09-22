Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7BB280255
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:43:25 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so153956111pab.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:43:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id ff7si2250913pab.275.2016.09.22.07.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 07:43:24 -0700 (PDT)
Date: Thu, 22 Sep 2016 22:43:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [kbuild-all] mm/slub.o:undefined reference to
 `_GLOBAL_OFFSET_TABLE_'
Message-ID: <20160922144318.urpvmj634kbmzvd7@wfg-t540p.sh.intel.com>
References: <201609221308.sGPlsAWm%fengguang.wu@intel.com>
 <20160922102946.4712077b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160922102946.4712077b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Michal Simek <monstr@monstr.eu>

Hi Jesper,

On Thu, Sep 22, 2016 at 10:29:46AM +0200, Jesper Dangaard Brouer wrote:
>On Thu, 22 Sep 2016 13:50:21 +0800
>kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> Hi Jesper,
>>
>> FYI, the error/warning still remains.
>>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   7d1e042314619115153a0f6f06e4552c09a50e13
>> commit: d0ecd894e3d5f768a84403b34019c4a7daa05882 slub: optimize bulk slowpath free by detached freelist
>> date:   10 months ago
>> config: microblaze-allnoconfig (attached as .config)
>> compiler: microblaze-linux-gcc (GCC) 6.2.0
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout d0ecd894e3d5f768a84403b34019c4a7daa05882
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=microblaze
>>
>> All errors (new ones prefixed by >>):
>>
>>    mm/built-in.o: In function `__slab_free.isra.14':
>> >> mm/slub.o:(.text+0x28d1c): undefined reference to `_GLOBAL_OFFSET_TABLE_'
>>    scripts/link-vmlinux.sh: line 52: 18051 Segmentation fault      ${LD} ${LDFLAGS} ${LDFLAGS_vmlinux} -o ${2} -T ${lds} ${KBUILD_VMLINUX_INIT} --start-group ${KBUILD_VMLINUX_MAIN} --end-group ${1}
>
>Hi Fengguang,
>
>I don't really understand if this is a real bug that I need to fix?
>
>It looks like a linker problem, resulting in a "Segmentation fault" for your script...
>
>The mentioned commit: d0ecd894e3d5f768a84 removes a call point to
>__slab_free() and instead call slab_free().  It does not make sense to
>my, why this results in a linker error on this ARCH=microblaze.

Yes this looks strange. CC Michal since such errors only show up in
microblaze:

linus/master errors
a??a??a?? microblaze-allnoconfig
a??A A  a??a??a?? mm-slub.o:(.text):undefined-reference-to-_GLOBAL_OFFSET_TABLE_
a??a??a?? microblaze-mmu_defconfig
a??A A  a??a??a?? net-sunrpc-stats.c:undefined-reference-to-_GLOBAL_OFFSET_TABLE_
a??a??a?? microblaze-nommu_defconfig
a??A A  a??a??a?? net-sunrpc-stats.c:undefined-reference-to-_GLOBAL_OFFSET_TABLE_


I can reproduce the error in commit d0ecd894e3d5f768a84, and
confirmed that it's parent commit builds fine.

=============== commit 461a5e510 ===============
/home/wfg/linux
HEAD is now at 461a5e5... do_div(): generic optimization for constant divisor on 32-bit machines
/home/wfg/linux/obj-compiletest

make ARCH=microblaze

!!! BUILD ERROR !!!
cat /tmp/build-err-461a5e51060c93f5844113f4be9dba513cc92830-wfg
<stdin>:1298:2: warning: #warning syscall userfaultfd not implemented [-Wcpp]
<stdin>:1301:2: warning: #warning syscall membarrier not implemented [-Wcpp]
<stdin>:1304:2: warning: #warning syscall mlock2 not implemented [-Wcpp]
<stdin>:1298:2: warning: #warning syscall userfaultfd not implemented [-Wcpp]
<stdin>:1301:2: warning: #warning syscall membarrier not implemented [-Wcpp]
<stdin>:1304:2: warning: #warning syscall mlock2 not implemented [-Wcpp]
../net/core/rtnetlink.c:1361:32: warning: 'ifla_vf_stats_policy' defined but not used [-Wunused-const-variable=]
 static const struct nla_policy ifla_vf_stats_policy[IFLA_VF_STATS_MAX + 1] = {
                                ^~~~~~~~~~~~~~~~~~~~
../net/core/net-sysfs.c:32:19: warning: 'fmt_long_hex' defined but not used [-Wunused-const-variable=]
 static const char fmt_long_hex[] = "%#lx\n";
                   ^~~~~~~~~~~~
../fs/proc/base.c:2239:37: warning: 'proc_timers_operations' defined but not used [-Wunused-const-variable=]
 static const struct file_operations proc_timers_operations = {
                                     ^~~~~~~~~~~~~~~~~~~~~~
../fs/cifs/netmisc.c:133:40: warning: 'mapping_table_ERRHRD' defined but not used [-Wunused-const-variable=]
 static const struct smb_to_posix_error mapping_table_ERRHRD[] = {
                                        ^~~~~~~~~~~~~~~~~~~~
../net/ipv4/ping.c:1139:36: warning: 'ping_v4_seq_ops' defined but not used [-Wunused-const-variable=]
 static const struct seq_operations ping_v4_seq_ops = {
                                    ^~~~~~~~~~~~~~~
net/built-in.o: In function `rpc_print_iostats':
/home/wfg/linux/obj-compiletest/../net/sunrpc/stats.c:204: undefined reference to `_GLOBAL_OFFSET_TABLE_'
../scripts/link-vmlinux.sh: line 52: 98396 Segmentation fault      ${LD} ${LDFLAGS} ${LDFLAGS_vmlinux} -o ${2} -T ${lds} ${KBUILD_VMLINUX_INIT} --start-group ${KBUILD_VMLINUX_MAIN} --end-group ${1}
make[1]: *** [vmlinux] Error 139
make[1]: Target '_all' not remade because of errors.
make: *** [sub-make] Error 2


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
