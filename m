Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED3576B026C
	for <linux-mm@kvack.org>; Tue,  4 May 2010 06:53:07 -0400 (EDT)
Message-ID: <4BDFFCC4.5000106@cn.fujitsu.com>
Date: Tue, 04 May 2010 18:53:56 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH -V2 0/2] fix oom happening when changing cpuset'mems(was:
 [regression] cpuset,mm: update tasks' mems_allowed in time (58568d2))
Content-Type: multipart/mixed;
 boundary="------------080901000208050906050704"
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080901000208050906050704
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Nick Piggin reported that the allocator may see an empty nodemask when changing
cpuset's mems[1]. It happens only on the kernel that do not do atomic nodemask_t
stores. (MAX_NUMNODES > BITS_PER_LONG)

But I found that there is also a problem on the kernel that can do atomic
nodemask_t stores. The problem is that the allocator can't find a node to
alloc page when changing cpuset's mems though there is a lot of free memory.
The reason is like this:
(mpol: mempolicy)
	task1			task1's mpol	task2
	alloc page		1
	  alloc on node0? NO	1
				1		change mems from 1 to 0
				1		rebind task1's mpol
				0-1		  set new bits
				0	  	  clear disallowed bits
	  alloc on node1? NO	0
	  ...
	can't alloc page
	  goto oom

I can use the attached program reproduce it by the following step:
# mkdir /dev/cpuset
# mount -t cpuset cpuset /dev/cpuset
# mkdir /dev/cpuset/1
# echo `cat /dev/cpuset/cpus` > /dev/cpuset/1/cpus
# echo `cat /dev/cpuset/mems` > /dev/cpuset/1/mems
# echo $$ > /dev/cpuset/1/tasks
# numactl --membind=`cat /dev/cpuset/mems` ./cpuset_mem_hog <nr_tasks> &
   <nr_tasks> = max(nr_cpus - 1, 1)
# killall -s SIGUSR1 cpuset_mem_hog
# ./change_mems.sh

several hours later, oom will happen though there is a lot of free memory.

This patchset fixes this problem by expanding the nodes range first(set newly
allowed bits) and shrink it lazily(clear newly disallowed bits). So we use a
variable to tell the write-side task that read-side task is reading nodemask,
and the write-side task clears newly disallowed nodes after read-side task ends
the current memory allocation.

Changelog since V1:
- restructure the mempolicy's rebind functions, and split the rebind work to
  two steps because the rebind functions may breaks the first step - expanding
  the nodes range.

Thanks
Miao

[1] http://lkml.org/lkml/2010/2/18/111

[PATCH 1/2] mempolicy: restructure rebinding-mempolicy functions
[PATCH 2/2] cpuset,mm: fix no node to alloc memory when changing cpuset's mems

--------------080901000208050906050704
Content-Type: application/gzip;
 name="reproduce_prog.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="reproduce_prog.tar.gz"

H4sIAHwx0UsAA+1Xe0/bSBDPv/anGAJCTpqH7eYhHQQpKqFCAoLyOO7EIWuxN8kKx478gHLX
fvfOrO2QB4iexBWd6p8UeT3v2ZnZrGv1gC8C34ltbuFzWi+8PXREu91Mnq31Z4qCYXxsNUzT
MHSjoBsNQ28WoPkfxLKFOIxYAFCYC+Z/EfxFudf4/1PUNutvL+KQR9acz62ZP63Zb+CDCtxq
NV6q/8eWYWb119u41o222dILoL+B71fxi9d/V3i2GzscDsPIEX5tdqSukVxxu06LPYHkTblA
eNN1mh09Lvg6iQfBhp6YeszdoD2GdVINt8lYqWib+sDEM9T5nHlEVXcdPhEeh/HFeNg7VhTL
YhGGextH3LJA02IP+90plVT13ndZJFwOwouAe84BkYQDGOWMeY7LA0NLrEgJCt4vqf+o37bk
zGflFLQJHTAOSIM46YxppC0FUJRmT+rg4kBVXN+bwoJNeSj+5vgee2SOOyAZZeY4AVLJWEDy
qpLJoqMpj7I3rUQ8MQEN1fl8ET2ieW0/cVOCQ9BLqqJgfTSjAsVVmVIRVWVgcbjABJZKZPBh
Rtul7SC9BBi/QvGgZ9z8hXYxPjurLGOHMhh6BS4H/ZE16HWP4WuyvhqcjnoVVFWU8+6ldTk4
/b076iGX3roX/Ys/z/vjYQWqGJhOocgsEj8dKXTSPT3rHSf+FdyFZItxvcB8/EArUjQwYRiq
U/vLk/koym3A2R2tvuEPC0G5klX08uWkvRG3VJnHHqWVCG2xsaTkPA68pBJZiZnwNFqwYGpX
wJ7hWVMu48u9LDhxvIiFd2FaRfFUTcxDT9+o8WMSwUGLbdkezI6E70HIcF9CZiJvIRzsnDI+
wqzY5BR2OmCuVtdfSE0RwkOATVQrylImUaBPFvmCFO+vjZtl16Tcw856o6RkNBXOmeumpigC
agKk+HamWgbaLn+iyTBLtGVkeIeEV01KJRZxkFbSqiV2MddayKx0xtDDymAePNfdifwc/b/e
4kvzE5dNw2zvE5PJXmvD08/j4QC19+WuU38/ZzeVXlo1XwrafD5o898Fbf5I0KYM2vzRoCd+
AJqQ9kCgdNqiID58SOaMinMtblACRe+05VxmdHKQDGQ2hInc1hiuzuvTSAJ3QzyGs/5Ai6VU
mOYrOzazsSM5QW2ehJk4XvYzTVR2UFWrAo7SHlbuhOtmAVcg3afMZqqQWKlWE5v0T4MVksO4
TPnq9KT3B55hx1rKgP19uCLScNQdjYcZubSe7vZ58T7//9v3P+zOKaf7X1gLZ2/i47X7v9lo
Le//egPviUarbZr5/e9nYHenfiu8ejhT1U+XeGfBf+d+f9Qp1h1+n34LFFVsZevzoD++7BT3
VqTqRlE9750PrRP8B0bWUqxO3VNUJbNT1HGVzNM1GHCjOj5eheyZD3vEh6PkKY2oilTZ07Qd
ScSpcXyPv9Ns/ArYmv9zdocXZvctG11+/zVe/P7Tcfaf5p/OCaPZbObffz8FeN/6TVWmtg2b
H/5Q9Tdoqmq7nHkoH8yhOtnkvncqOXLkyJEjR44cOXLkyJEjR44cOXLkyJFjBd8BQ7XGowAo
AAA=
--------------080901000208050906050704--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
