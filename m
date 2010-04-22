Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0DA966B01F9
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:14:43 -0400 (EDT)
Message-ID: <4BD05900.7040203@cn.fujitsu.com>
Date: Thu, 22 Apr 2010 22:11:12 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH 0/2] fix oom happening when changing cpuset'mems(was: [regression]
 cpuset,mm: update tasks' mems_allowed in time (58568d2))
Content-Type: multipart/mixed;
 boundary="------------020700000103080306030400"
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020700000103080306030400
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Nick Piggin reported that the allocator may see an empty nodemask when
changing cpuset's mems.

The problem is that:
Cpuset updates task->mems_allowed and mempolicy by setting all new bits
in the nodemask first, and clearing all old unallowed bits later.
But the allocator may load a word of the mask before setting all new bits
and then load another word of the mask after clearing all old unallowed
bits, in this way, the allocator sees an empty nodemask.

It happens only on the kernel that do not do atomic nodemask_t stores.
(MAX_NUMNODES > BITS_PER_LONG)

But I found that there is also a problem on the kernel that can do atomic
nodemask_t stores. The problem is that the allocator can't find a node to
alloc page when changing cpuset's mems though there is a lot of free memory.

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

The problem is following:
	task1					task2
	mmap()				mems=1
	  Can alloc page on node0? NO	mems=1
					mems=0	change mems from 1 to 0
					mems=0-1  set all new bits
					mems=0	  clear all disallowed bits
	  Can alloc page on node1? NO	mems=0
	  ...
	can't alloc page
	  goto oom

this patchset fixes those problems.

Thanks
Miao

--------------020700000103080306030400
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
--------------020700000103080306030400--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
