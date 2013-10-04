Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C28366B0031
	for <linux-mm@kvack.org>; Fri,  4 Oct 2013 16:30:33 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so4643439pad.21
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 13:30:33 -0700 (PDT)
Message-ID: <524F2592.1040305@gmail.com>
Date: Fri, 04 Oct 2013 16:31:14 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/26] get_user_pages() cleanup
References: <1380724087-13927-1-git-send-email-jack@suse.cz> <20131002162009.GA5778@infradead.org> <20131002202941.GF16998@quack.suse.cz>
In-Reply-To: <20131002202941.GF16998@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Andy Walls <awalls@md.metrocast.net>, Arnd Bergmann <arnd@arndb.de>, Benjamin LaHaise <bcrl@kvack.org>, ceph-devel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Gleb Natapov <gleb@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, hpdd-discuss@ml01.01.org, Jarod Wilson <jarod@wilsonet.com>, Jayant Mangalampalli <jayant.mangalampalli@intel.com>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Kai Makisara <Kai.Makisara@kolumbus.fi>, kvm@vger.kernel.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-aio@kvack.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-media@vger.kernel.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org, Manu Abraham <abraham.manu@gmail.com>, Mark Allyn <mark.a.allyn@intel.com>, Mikael Starvik <starvik@axis.com>, Mike Marciniszyn <infinipath@intel.com>, Naren Sankar <nsankar@broadcom.com>, Paolo Bonzini <pbonzini@redhat.com>, Peng Tao <tao.peng@emc.com>, Roland Dreier <roland@kernel.org>, Sage Weil <sage@inktank.com>, Scott Davilla <davilla@4pi.com>, Timur Tabi <timur@freescale.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, kosaki.motohiro@gmail.com

(10/2/13 4:29 PM), Jan Kara wrote:
> On Wed 02-10-13 09:20:09, Christoph Hellwig wrote:
>> On Wed, Oct 02, 2013 at 04:27:41PM +0200, Jan Kara wrote:
>>>    Hello,
>>>
>>>    In my quest for changing locking around page faults to make things easier for
>>> filesystems I found out get_user_pages() users could use a cleanup.  The
>>> knowledge about necessary locking for get_user_pages() is in tons of places in
>>> drivers and quite a few of them actually get it wrong (don't have mmap_sem when
>>> calling get_user_pages() or hold mmap_sem when calling copy_from_user() in the
>>> surrounding code). Rather often this actually doesn't seem necessary. This
>>> patch series converts lots of places to use either get_user_pages_fast()
>>> or a new simple wrapper get_user_pages_unlocked() to remove the knowledge
>>> of mmap_sem from the drivers. I'm still looking into converting a few remaining
>>> drivers (most notably v4l2) which are more complex.
>>
>> Even looking over the kerneldoc comment next to it I still fail to
>> understand when you'd want to use get_user_pages_fast and when not.
>    AFAIU get_user_pages_fast() should be used
> 1) if you don't need any special get_user_pages() arguments (like calling
>     it for mm of a different process, forcing COW, or similar).
> 2) you don't expect pages to be unmapped (then get_user_pages_fast() is
> actually somewhat slower because it walks page tables twice).

If target page point to anon or private mapping pages, get_user_pages_fast()
is fork unsafe. O_DIRECT man pages describe a bit about this.


see http://man7.org/linux/man-pages/man2/open.2.html

>       O_DIRECT I/Os should never be run concurrently with the fork(2)
>       system call, if the memory buffer is a private mapping (i.e., any
>       mapping created with the mmap(2) MAP_PRIVATE flag; this includes
>       memory allocated on the heap and statically allocated buffers).  Any
>       such I/Os, whether submitted via an asynchronous I/O interface or
>       from another thread in the process, should be completed before
>       fork(2) is called.  Failure to do so can result in data corruption
>       and undefined behavior in parent and child processes.  This
>       restriction does not apply when the memory buffer for the O_DIRECT
>       I/Os was created using shmat(2) or mmap(2) with the MAP_SHARED flag.
>       Nor does this restriction apply when the memory buffer has been
>       advised as MADV_DONTFORK with madvise(2), ensuring that it will not
>       be available to the child after fork(2).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
