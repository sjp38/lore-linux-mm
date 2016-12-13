Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E481F6B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:08:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so1756505pgc.5
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:08:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f15si49570483plm.7.2016.12.13.14.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 14:08:40 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
References: <20161213181511.GB2305@redhat.com> <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com> <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4accd272-7214-c702-aed3-fb131f178162@intel.com>
Date: Tue, 13 Dec 2016 14:08:22 -0800
MIME-Version: 1.0
In-Reply-To: <20161213212433.GF2305@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, "Williams, Dan J" <dan.j.williams@intel.com>

On 12/13/2016 01:24 PM, Jerome Glisse wrote:
> 
>>> > > From kernel point of view such memory is almost like any other, it
>>> > > has a struct page and most of the mm code is non the wiser, nor need
>>> > > to be about it. CPU access trigger a migration back to regular CPU
>>> > > accessible page.
>> > 
>> > That sounds ... complex. Page migration on page cache access inside
>> > the filesytem IO path locking during read()/write() sounds like
>> > a great way to cause deadlocks....
> There are few restriction on device page, no one can do GUP on them and
> thus no one can pin them. Hence they can always be migrated back. Yes
> each fs need modification, most of it (if not all) is isolated in common
> filemap helpers.

Huh, that's pretty different from the other ZONE_DEVICE uses.  For
those, you *can* do get_user_pages().

I'd be really interested to see the feature set that these pages have
and how it differs from regular memory and the ZONE_DEVICE memory that
have have in-kernel today.

BTW, how is this restriction implemented?  I would have expected to see
follow_page_pte() or vm_normal_page() getting modified.  I don't see a
single reference to get_user_pages or "GUP" in any of the latest HMM
patch set or the changelogs.

As best I can tell, the slow GUP path will get stuck in a loop inside
follow_page_pte(), while the fast GUP path will allow you to acquire a
reference to the page.  But, maybe I'm reading the code wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
