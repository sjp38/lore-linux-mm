Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 881FF830A0
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 15:21:17 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so180992069ywa.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 12:21:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s142si1239370qke.156.2016.04.21.12.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 12:21:16 -0700 (PDT)
Date: Thu, 21 Apr 2016 20:21:10 +0100
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: post-copy is broken?
Message-ID: <20160421192110.GA27954@work-vm>
References: <20160415125236.GA3376@node.shutemov.name>
 <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name>
 <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
 <20160420172754.GJ2263@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160420172754.GJ2263@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Li, Liang Z" <liang.z.li@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Andrea,

I'm wondering if this bug is the opposite way around from what I originally
thought it was - I don't think the problem is 0 pages on the destination; I think
it's more subtle.

I added some debug to print the source VMs memory and also
the byte in the destination's 1st page (this is in the nest):

nhp_range: block: pc.ram @ 0x7fc59a800000
Destination 1st byte: e8,df <stop> df

   OK, so that tells us that the destination is running OK, and that it
stops running when we tell it to.

Memory content inconsistency at f79000 first_byte = df last_byte = de current = 9 hit_edge = 1 src_byte = 9

'src_byte' is saying that the source VM had the byte 9 in that page (we've still got the source VMs memory - it's
paused at this point in the test)
  so adding the start of pc.ram we get that being a host address of 0x7FC59B779000 and in the logs I see:
postcopy_place_page: 0x55ba64503f7d->0x7fc59b779000 copy=4096 1stbyte=9/9

  OK, so that shows that when the destination received the page it was also '9' and after the uffdio_copy
it read as 9 - so the page made it into RAM; it wasn't 0.

But that also means, that page hasn't changed *after* migration; why not?

We can see that the other pages are changing (that Destination 1st byte
line shows the 1st byte of the test memory changed) - so the incrementer
loop has apparently incremented every byte of the test memory multiple
times - except these pages are still stuck at the '9' it got when we
placed the page into it atomically.

I've been unable to trigger this bug in a standalone test case that ran
without kvm.

Is it possible that the guest KVM CPU isn't noticing some change to
the mapping?

Dave


--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
