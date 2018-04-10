Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4386B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 20:26:14 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v74so7270957qkl.9
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 17:26:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k64si1820495qkd.422.2018.04.09.17.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 17:26:12 -0700 (PDT)
Date: Tue, 10 Apr 2018 08:26:07 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v3 2/4] mm/sparsemem: Defer the ms->section_mem_map
 clearing
Message-ID: <20180410002607.GK19345@localhost.localdomain>
References: <20180228032657.32385-1-bhe@redhat.com>
 <20180228032657.32385-3-bhe@redhat.com>
 <8e147320-50f5-f809-31d2-992c35ecc418@intel.com>
 <20180408065055.GA19345@localhost.localdomain>
 <fa2bb08a-42cc-c0cc-31c0-39d6e14f6f92@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa2bb08a-42cc-c0cc-31c0-39d6e14f6f92@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 04/09/18 at 09:02am, Dave Hansen wrote:
> On 04/07/2018 11:50 PM, Baoquan He wrote:
> >> Should the " = 0" instead be clearing SECTION_MARKED_PRESENT or
> >> something?  That would make it easier to match the code up with the code
> >> that it is effectively undoing.
> > 
> > Not sure if I understand your question correctly. From memory_present(),
> > information encoded into ms->section_mem_map including numa node,
> > SECTION_IS_ONLINE and SECTION_MARKED_PRESENT. Not sure if it's OK to only
> > clear SECTION_MARKED_PRESENT.  People may wrongly check SECTION_IS_ONLINE
> > and do something on this memory section?
> 
> What is mean is that, instead of:

I mean that in memory_present() all present sections are marked with
below information.

	ms->section_mem_map = (nid << SECTION_NID_SHIFT) |
			      SECTION_MARKED_PRESENT |
			      SECTION_IS_ONLINE;

Later in sparse_init(), if we failed to allocate mem map, the
corresponding section need clear its ->section_mem_map. The existing
code does the clearing with: 

	ms->section_mem_map = 0;

If with 'ms->section_mem_map &= ~SECTION_MARKED_PRESENT', the nid and
SECTION_IS_ONLINE are still left in ms->section_mem_map. Someone may
probably mistakenly check if this section is online and do something, or
still get nid from this section. Just worried.

> 
> 	
> 	ms->section_mem_map = 0;
> 
> we could literally do:
> 
> 	ms->section_mem_map &= ~SECTION_MARKED_PRESENT;
> 
> That does the same thing in practice, but makes the _intent_ much more
> clear.
