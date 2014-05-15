Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id ECA1F6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 13:36:33 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so1375293pbc.23
        for <linux-mm@kvack.org>; Thu, 15 May 2014 10:36:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id wh4si3020024pbc.262.2014.05.15.10.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 May 2014 10:36:33 -0700 (PDT)
Message-ID: <5374FA04.5@oracle.com>
Date: Thu, 15 May 2014 13:31:48 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <515D882E.6040001@oracle.com> <533F09F0.1050206@oracle.com> <20140407144835.GA17774@node.dhcp.inet.fi> <5342FF3E.6030306@oracle.com> <20140407201106.GA21633@node.dhcp.inet.fi>
In-Reply-To: <20140407201106.GA21633@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Josh Boyer <jwboyer@fedoraproject.org>

On 04/07/2014 04:11 PM, Kirill A. Shutemov wrote:
> On Mon, Apr 07, 2014 at 03:40:46PM -0400, Sasha Levin wrote:
>> > It also breaks fairly quickly under testing because:
>> > 
>> > On 04/07/2014 10:48 AM, Kirill A. Shutemov wrote:
>>> > > +	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
>>> > > +		spin_lock(ptl);
>> > 
>> > ^ We go into atomic
>> > 
>>> > > +		if (unlikely(!pmd_same(*pmd, orig_pmd)))
>>> > > +			goto out_race;
>>> > > +	}
>>> > > +
>>> > >  	if (!page)
>>> > >  		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
>>> > >  	else
>>> > >  		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>> > 
>> > copy_user_huge_page() doesn't like running in atomic state,
>> > and asserts might_sleep().
> Okay, I'll try something else.

I've Cc'ed Josh Boyer to this since it just occurred to me that Fedora
is running with CONFIG_DEBUG_VM set, where this bug is rather easy to
trigger.

This issue was neglected because it triggers only on CONFIG_DEBUG_VM builds,
but with Fedora running that, maybe it shouldn't be?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
