Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 865B86B05D3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:23:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w187so115443832pgb.10
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 01:23:39 -0700 (PDT)
Received: from out28-1.mail.aliyun.com (out28-1.mail.aliyun.com. [115.124.28.1])
        by mx.google.com with ESMTP id p7si15935793pgr.476.2017.07.31.01.23.37
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 01:23:38 -0700 (PDT)
Subject: Re: [PATCH] mm: don't zero ballooned pages
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
 <20170731065508.GE13036@dhcp22.suse.cz> <597EDF3D.8020101@intel.com>
 <20170731075153.GD15767@dhcp22.suse.cz>
From: ZhenweiPi <zhenwei.pi@youruncloud.com>
Message-ID: <32d9c53d-5310-25a7-0348-a6cf362a5dcd@youruncloud.com>
Date: Mon, 31 Jul 2017 16:23:26 +0800
MIME-Version: 1.0
In-Reply-To: <20170731075153.GD15767@dhcp22.suse.cz>
Content-Type: multipart/alternative;
 boundary="------------6D5E7FF87C0442A7CF024327"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org

This is a multi-part message in MIME format.
--------------6D5E7FF87C0442A7CF024327
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 07/31/2017 03:51 PM, Michal Hocko wrote:

> On Mon 31-07-17 15:41:49, Wei Wang wrote:
>> >On 07/31/2017 02:55 PM, Michal Hocko wrote:
>>> > >On Mon 31-07-17 12:13:33, Wei Wang wrote:
>>>> > >>Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
>>>> > >>shouldn't be given to the host ksmd to scan.
>>> > >Could you point me where this MADV_DONTNEED is done, please?
>> >
>> >Sure. It's done in the hypervisor when the balloon pages are received.
>> >
>> >Please see line 40 at
>> >https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c
> And one more thing. I am not familiar with ksm much. But how is
> MADV_DONTNEED even helping? This madvise is not sticky - aka it will
> unmap the range without leaving any note behind. AFAICS the only way
> to have vma scanned is to have VM_MERGEABLE and that is an opt in:
> See Documentation/vm/ksm.txt
> "
> KSM only operates on those areas of address space which an application
> has advised to be likely candidates for merging, by using the madvise(2)
> system call: int madvise(addr, length, MADV_MERGEABLE).
> "
>
> So what exactly is going on here? The original patch looks highly
> suspicious as well. If somebody wants to make that memory mergable then
> the user of that memory should zero them out.

Kernel starts a kthread named "ksmd". ksmd scans the VM_MERGEABLE

memory, and merge the same pages.(same page means memcmp(page1,

page2, PAGESIZE) == 0).

Guest can not use ballooned pages, and these pages will not be accessed

in a long time. Kswapd on host will swap these pages out and get more

free memory.

Rather than swapping, KSM has better performence.  Presently pages in

the balloon device have random value,  they usually cannot be merged.

So enqueue zero pages will resolve this problem.

Because MADV_DONTNEED depends on host os capability and hypervisor capability,
I prefer to enqueue zero pages to balloon device and made this patch.


--------------6D5E7FF87C0442A7CF024327
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p>On 07/31/2017 03:51 PM, Michal Hocko wrote:<br>
    </p>
    <blockquote cite="mid:20170731075153.GD15767@dhcp22.suse.cz"
      type="cite">
      <pre wrap="">On Mon 31-07-17 15:41:49, Wei Wang wrote:
</pre>
      <blockquote type="cite" style="color: #000000;">
        <pre wrap=""><span class="moz-txt-citetags">&gt; </span>On 07/31/2017 02:55 PM, Michal Hocko wrote:
</pre>
        <blockquote type="cite" style="color: #000000;">
          <pre wrap=""><span class="moz-txt-citetags">&gt; &gt;</span>On Mon 31-07-17 12:13:33, Wei Wang wrote:
</pre>
          <blockquote type="cite" style="color: #000000;">
            <pre wrap=""><span class="moz-txt-citetags">&gt; &gt;&gt;</span>Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
<span class="moz-txt-citetags">&gt; &gt;&gt;</span>shouldn't be given to the host ksmd to scan.
</pre>
          </blockquote>
          <pre wrap=""><span class="moz-txt-citetags">&gt; &gt;</span>Could you point me where this MADV_DONTNEED is done, please?
</pre>
        </blockquote>
        <pre wrap=""><span class="moz-txt-citetags">&gt; </span>
<span class="moz-txt-citetags">&gt; </span>Sure. It's done in the hypervisor when the balloon pages are received.
<span class="moz-txt-citetags">&gt; </span>
<span class="moz-txt-citetags">&gt; </span>Please see line 40 at
<span class="moz-txt-citetags">&gt; </span><a moz-do-not-send="true" class="moz-txt-link-freetext" href="https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c">https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c</a>
</pre>
      </blockquote>
      <pre wrap="">And one more thing. I am not familiar with ksm much. But how is
MADV_DONTNEED even helping? This madvise is not sticky - aka it will
unmap the range without leaving any note behind. AFAICS the only way
to have vma scanned is to have VM_MERGEABLE and that is an opt in:
See Documentation/vm/ksm.txt
"
KSM only operates on those areas of address space which an application
has advised to be likely candidates for merging, by using the madvise(2)
system call: int madvise(addr, length, MADV_MERGEABLE).
"

So what exactly is going on here? The original patch looks highly
suspicious as well. If somebody wants to make that memory mergable then
the user of that memory should zero them out.</pre>
    </blockquote>
    <pre>Kernel starts a kthread named "ksmd". ksmd scans the VM_MERGEABLE</pre>
    <pre>memory, and merge the same pages.(same page means memcmp(page1,</pre>
    <pre>page2, PAGESIZE) == 0). </pre>
    <pre>Guest can not use ballooned pages, and these pages will not be accessed</pre>
    <pre>in a long time. Kswapd on host will swap these pages out and get more </pre>
    <pre>free memory.</pre>
    <pre>Rather than swapping, KSM has better performence.  Presently pages in </pre>
    <pre>the balloon device have random value,  they usually cannot be merged.
</pre>
    <pre>So enqueue zero pages will resolve this problem.</pre>
    <pre>Because MADV_DONTNEED depends on host os capability and hypervisor capability,
I prefer to enqueue zero pages to balloon device and made this patch.
</pre>
  </body>
</html>

--------------6D5E7FF87C0442A7CF024327--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
