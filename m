Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7A66B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 18:03:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id p16so1326330qta.5
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:03:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h68si28770554qkd.292.2016.12.13.15.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 15:03:01 -0800 (PST)
Date: Tue, 13 Dec 2016 18:02:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213230257.GH2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <4accd272-7214-c702-aed3-fb131f178162@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4accd272-7214-c702-aed3-fb131f178162@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, "Williams, Dan J" <dan.j.williams@intel.com>

On Tue, Dec 13, 2016 at 02:08:22PM -0800, Dave Hansen wrote:
> On 12/13/2016 01:24 PM, Jerome Glisse wrote:
> > 
> >>> > > From kernel point of view such memory is almost like any other, it
> >>> > > has a struct page and most of the mm code is non the wiser, nor need
> >>> > > to be about it. CPU access trigger a migration back to regular CPU
> >>> > > accessible page.
> >> > 
> >> > That sounds ... complex. Page migration on page cache access inside
> >> > the filesytem IO path locking during read()/write() sounds like
> >> > a great way to cause deadlocks....
> > There are few restriction on device page, no one can do GUP on them and
> > thus no one can pin them. Hence they can always be migrated back. Yes
> > each fs need modification, most of it (if not all) is isolated in common
> > filemap helpers.
> 
> Huh, that's pretty different from the other ZONE_DEVICE uses.  For
> those, you *can* do get_user_pages().
> 
> I'd be really interested to see the feature set that these pages have
> and how it differs from regular memory and the ZONE_DEVICE memory that
> have have in-kernel today.

Well i can do a list for current patchset where i do not allow migration
of file back page. Roughly you can not kmap and GUP. But GUP has many more
implications like direct I/O (source or destination of direct I/O) ...

> 
> BTW, how is this restriction implemented?  I would have expected to see
> follow_page_pte() or vm_normal_page() getting modified.  I don't see a
> single reference to get_user_pages or "GUP" in any of the latest HMM
> patch set or the changelogs.
> 
> As best I can tell, the slow GUP path will get stuck in a loop inside
> follow_page_pte(), while the fast GUP path will allow you to acquire a
> reference to the page.  But, maybe I'm reading the code wrong.

It is a side effect of having a special swap pte so follow_page_pte()
returns NULL which trigger page fault through handle_mm_fault() which
trigger migration back to regular page. Same for fast GUP version.
There is never a valid pte for an un-addressable page.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
