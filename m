Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7629A6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:28:09 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so18975463wes.10
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 03:28:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce3si11053280wib.0.2015.01.21.03.28.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 03:28:07 -0800 (PST)
Message-ID: <54BF8D45.7030205@suse.cz>
Date: Wed, 21 Jan 2015 12:28:05 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org> <54BD308A.4080905@suse.cz> <87fvb6uhfp.fsf@linux.vnet.ibm.com> <54BE1B00.3090102@suse.cz>
In-Reply-To: <54BE1B00.3090102@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/20/2015 10:08 AM, Vlastimil Babka wrote:
> On 01/20/2015 06:52 AM, Aneesh Kumar K.V wrote:
>> Vlastimil Babka <vbabka@suse.cz> writes:
>> 
>> is that check correct ? ie, 
>> 
>> if ((gfp & GFP_TRANSHUGE) == GFP_TRANSHUGE)
>> 
>> may not always indicate transparent hugepage if defrag = 0 . With defrag
>> cleared, we remove __GFP_WAIT from GFP_TRANSHUGE.
> 
> Yep, that looks wrong. Sigh. I guess we can't spare an extra GFP flag to
> indicate TRANSHUGE?

I wanted to fix this in __alloc_pages_slowpath(), but actually there's no issue
(other than being quite subtle) - if defrag == 0 and thus we don't have
__GFP_WAIT, we reach "if (!wait) goto nopage;" and bail out before reaching the
checks for GFP_TRANSHUGE.

>> static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
>> {
>> 	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
>> }
>> 
>> -aneesh
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
