Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 69E1A6B01FA
	for <linux-mm@kvack.org>; Sun, 25 Apr 2010 16:42:03 -0400 (EDT)
Message-ID: <4BD4A917.70702@tauceti.net>
Date: Sun, 25 Apr 2010 22:41:59 +0200
From: Robert Wimmer <kernel@tauceti.net>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
References: <4BC32527.9090301@tauceti.net> <20100412135223.GA17887@redhat.com> <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com>
In-Reply-To: <20100425091759.GA9993@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I've added CONFIG_KALLSYMS and CONFIG_KALLSYMS_ALL
to my .config. I've uploaded the dmesg output. Maybe it
helps a little bit:

https://bugzilla.kernel.org/attachment.cgi?id=26138

- Robert


On 04/25/10 11:18, Michael S. Tsirkin wrote:
> On Fri, Apr 23, 2010 at 07:26:52AM +0200, Robert Wimmer wrote:
>   
>>> I'm not sure why the lockup backtrace does not show function names -
>>> is the kernel stripped?
>>>       
>> I'm building the kernels always with "genkernel" a Gentoo
>> helper programm for kernel building. But I've looked into
>> the log file of genkernel and there is nothing mentioned about
>> striping the kernel. There will be a future release of genkernel
>> which supports this but this is currently not the case. Since
>> I haven't stripped the kernel I would answer no. Maybe a
>> kernel option which should be enabled?
>>
>> Thanks!
>> Robert
>>
>>     
> Hmm. I have these
> CONFIG_KALLSYMS=y
> CONFIG_KALLSYMS_ALL=y
> CONFIG_KALLSYMS_EXTRA_PASS=y
> # CONFIG_STRIP_ASM_SYMS is not set
>
>
>   
>>
>> On 04/22/10 12:03, Michael S. Tsirkin wrote:
>>     
>>> On Thu, Apr 22, 2010 at 01:31:06PM +0200, kernel wrote:
>>>   
>>>       
>>>> Maybe some comments to my former mail about what I've done:
>>>> I started with a fresh clone (deleted the old /usr/src/linux
>>>> of course). 
>>>>
>>>> git clone
>>>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git linux
>>>>
>>>> Then I started bisect
>>>>
>>>> git bisect start 'v2.6.31' 'v2.6.30'
>>>>
>>>> and build the first kernel and then marked kernels which
>>>> "crashed" with "soft lockup" or "swapper page allocation failure"
>>>> as bad and the other ones as good. Before I've compiled
>>>> a new kernel I've always done a "make mrproper". I don't know
>>>> if this is needed but thought it wouldn't hurt.
>>>>
>>>> For me it was not clear that maybe I should have had stopped
>>>> testing after the first commit that came up with a "swapper
>>>> page allocation failure". It was only one commit which cased
>>>> the allocation failure. All the other commits marked as bad
>>>> came up with a soft lockup. But I thought it is important to
>>>> find the earliest commit which crashes. So should I find out
>>>> the commit with the allocation failure?
>>>>     
>>>>         
>>> I think you did the right thing. We'll have to
>>> figure out soft lockup thing, then if page allocation failure
>>> turns out to be a different issue, look at it.
>>>
>>>   
>>>       
>>>> As you requested I've now done now a
>>>>
>>>> git checkout c02d7adf8c5429727a98bad1d039bccad4c61c50
>>>>
>>>> which ended with a soft lockup within 3 min. after starting
>>>> the VM (see
>>>> https://bugzilla.kernel.org/attachment.cgi?id=26089&action=edit)
>>>> with this kernel.
>>>>     
>>>>         
>>> I'm not sure why the lockup backtrace does not show function names -
>>> is the kernel stripped?
>>>
>>>   
>>>       
>>>> Then I've done a
>>>>
>>>> git checkout cf8d2c11cb77f129675478792122f50827e5b0ae
>>>>
>>>> compiled and restarted the VM with this kernel version
>>>> (BTW: Of course I've always used the same .config for 
>>>> all kernels I've build.). cf8d2c11cb77f129675478792122f50827e5b0ae
>>>> is running fine.
>>>>
>>>> Thanks!
>>>> Robert
>>>>     
>>>>         
>>> Well, so the soft lockup issue seems NFS-related?
>>> Trond, commit cf8d2c11cb77f129675478792122f50827e5b0ae seems to
>>> be causing problems on some old kernels (See bisect below). Any idea why?
>>>
>>>
>>>   
>>>       
>>>> On Wed, 21 Apr 2010 12:42:49 +0300, "Michael S. Tsirkin" <mst@redhat.com>
>>>> wrote:
>>>>     
>>>>         
>>>>> On Wed, Apr 21, 2010 at 01:23:12PM +0200, kernel wrote:
>>>>>       
>>>>>           
>>>>>> So after the compiler was running hot I've now the following result:
>>>>>>
>>>>>> server10:/usr/src/linux # git bisect log 
>>>>>> # bad: [74fca6a42863ffacaf7ba6f1936a9f228950f657] Linux 2.6.31
>>>>>> # good: [07a2039b8eb0af4ff464efd3dfd95de5c02648c6] Linux 2.6.30
>>>>>> git bisect start 'v2.6.31' 'v2.6.30'
>>>>>> # good: [925d74ae717c9a12d3618eb4b36b9fb632e2cef3] V4L/DVB (11736):
>>>>>> videobuf: modify return value of VIDIOC_REQBUFS ioctl
>>>>>> git bisect good 925d74ae717c9a12d3618eb4b36b9fb632e2cef3
>>>>>> # bad: [a380137900fca5c79e6daa9500bdb6ea5649188e] ixgbe: Fix device
>>>>>> capabilities of 82599 single speed fiber NICs.
>>>>>> git bisect bad a380137900fca5c79e6daa9500bdb6ea5649188e
>>>>>> # good: [1dbb5765acc7a6fe4bc1957c001037cc9d02ae03] Staging: android:
>>>>>> lowmemorykiller: fix up remaining checkpatch warnings
>>>>>> git bisect good 1dbb5765acc7a6fe4bc1957c001037cc9d02ae03
>>>>>> # good: [df36b439c5fedefe013d4449cb6a50d15e2f4d70] Merge branch
>>>>>> 'for-2.6.31' of git://git.linux-nfs.org/projects/trondmy/nfs-2.6
>>>>>> git bisect good df36b439c5fedefe013d4449cb6a50d15e2f4d70
>>>>>> # bad: [a800faec1b21d7133b5f0c8c6dac593b7c4e118d] Merge branch
>>>>>> 'for-linus'
>>>>>> of git://www.jni.nu/cris
>>>>>> git bisect bad a800faec1b21d7133b5f0c8c6dac593b7c4e118d
>>>>>> # good: [ac1b7c378ef26fba6694d5f118fe7fc16fee2fe2] Merge
>>>>>> git://git.infradead.org/mtd-2.6
>>>>>> git bisect good ac1b7c378ef26fba6694d5f118fe7fc16fee2fe2
>>>>>> # bad: [37c6dbe290c05023b47f52528e30ce51336b93eb] V4L/DVB (12091):
>>>>>> gspca_sonixj: Add light frequency control
>>>>>> git bisect bad 37c6dbe290c05023b47f52528e30ce51336b93eb
>>>>>> # bad: [687d680985b1438360a9ba470ece8b57cd205c3b] Merge
>>>>>> git://git.infradead.org/~dwmw2/iommu-2.6.31
>>>>>> git bisect bad 687d680985b1438360a9ba470ece8b57cd205c3b
>>>>>> # bad: [1053414068bad659479e6efa62a67403b8b1ec0a] Merge branch
>>>>>> 'for-linus'
>>>>>> of git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394-2.6
>>>>>> git bisect bad 1053414068bad659479e6efa62a67403b8b1ec0a
>>>>>> # good: [b01b4babbf204443b5a846a7494546501614cefc] firewire: net: fix
>>>>>> card
>>>>>> driver reloading
>>>>>> git bisect good b01b4babbf204443b5a846a7494546501614cefc
>>>>>> # bad: [c02d7adf8c5429727a98bad1d039bccad4c61c50] NFSv4: Replace
>>>>>> nfs4_path_walk() with VFS path lookup in a private namespace
>>>>>> git bisect bad c02d7adf8c5429727a98bad1d039bccad4c61c50
>>>>>> # good: [616511d039af402670de8500d0e24495113a9cab] VFS: Uninline the
>>>>>> function put_mnt_ns()
>>>>>> git bisect good 616511d039af402670de8500d0e24495113a9cab
>>>>>> # good: [cf8d2c11cb77f129675478792122f50827e5b0ae] VFS: Add VFS helper
>>>>>> functions for setting up private namespaces
>>>>>> git bisect good cf8d2c11cb77f129675478792122f50827e5b0ae
>>>>>>
>>>>>>
>>>>>> The last "git bisect good" prints out:
>>>>>>
>>>>>> server10:/usr/src/linux # git bisect good
>>>>>> c02d7adf8c5429727a98bad1d039bccad4c61c50 is the first bad commit
>>>>>> commit c02d7adf8c5429727a98bad1d039bccad4c61c50
>>>>>> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>>> Date:   Mon Jun 22 15:09:14 2009 -0400
>>>>>>
>>>>>>     NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private
>>>>>> namespace
>>>>>>     
>>>>>>     As noted in the previous patch, the NFSv4 client mount code
>>>>>>         
>>>>>>             
>>>> currently
>>>>     
>>>>         
>>>>>>     has several limitations. If the mount path contains symlinks, or
>>>>>>     referrals, or even if it just contains a '..', then the client code
>>>>>>     in
>>>>>>     nfs4_path_walk() will fail with an error.
>>>>>>     
>>>>>>     This patch replaces the nfs4_path_walk()-based lookup with a helper
>>>>>>     function that sets up a private namespace to represent the
>>>>>>         
>>>>>>             
>>>> namespace
>>>>     
>>>>         
>>>>>> on the
>>>>>>     server, then uses the ordinary VFS and NFS path lookup code to walk
>>>>>> down the
>>>>>>     mount path in that namespace.
>>>>>>     
>>>>>>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>>>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>>>>>
>>>>>> :040000 040000 97a18818f26ab9a0987f157257eb6f399c3cc1cc
>>>>>> 9ab6c712bb64f1349b5ac9f2020191abb5780ca0 M      fs
>>>>>>
>>>>>> Does this help you any further?
>>>>>>
>>>>>> Thanks!
>>>>>> Robert
>>>>>>         
>>>>>>             
>>>>> Looks suspiciously like some error in testing.
>>>>> Could you pls retest and verify again that
>>>>> cf8d2c11cb77f129675478792122f50827e5b0ae
>>>>> is good and c02d7adf8c5429727a98bad1d039bccad4c61c50 is bad?
>>>>>       
>>>>>           

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
