Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 722106B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 17:24:40 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id u7so48569670pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 14:24:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w28si7096896pfi.123.2015.12.21.14.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 14:24:39 -0800 (PST)
Date: Mon, 21 Dec 2015 14:24:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: initiallize all new zap_details fields before
 use
Message-Id: <20151221142438.cbd34f0e663a795e649cdfbc@linux-foundation.org>
In-Reply-To: <5675D423.6020806@oracle.com>
References: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
	<20151219195237.GA31380@node.shutemov.name>
	<5675D423.6020806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, mhocko@suse.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 19 Dec 2015 17:03:15 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> On 12/19/2015 02:52 PM, Kirill A. Shutemov wrote:
> > On Fri, Dec 18, 2015 at 08:04:51PM -0500, Sasha Levin wrote:
> >> > Commit "mm, oom: introduce oom reaper" forgot to initialize the two new fields
> >> > of struct zap_details in unmap_mapping_range(). This caused using stack garbage
> >> > on the call to unmap_mapping_range_tree().
> >> > 
> >> > Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> >> > ---
> >> >  mm/memory.c |    1 +
> >> >  1 file changed, 1 insertion(+)
> >> > 
> >> > diff --git a/mm/memory.c b/mm/memory.c
> >> > index 206c8cd..0e32993 100644
> >> > --- a/mm/memory.c
> >> > +++ b/mm/memory.c
> >> > @@ -2431,6 +2431,7 @@ void unmap_mapping_range(struct address_space *mapping,
> >> >  	details.last_index = hba + hlen - 1;
> >> >  	if (details.last_index < details.first_index)
> >> >  		details.last_index = ULONG_MAX;
> >> > +	details.check_swap_entries = details.ignore_dirty = false;
> > Should we use c99 initializer instead to make it future-proof?
> 
> I didn't do that to make these sort of failures obvious. In this case, if we would have
> used an initializer and it would default to the "wrong" values it would be much harder
> to find this bug.
> 

If we're to make that approach useful and debuggable we should poison
the structure at the outset with some well-known and crazy pattern.  Or
use kasan.

But I don't think we need any special treatment here so yes, the
conventional way of zapping everything is best, IMO.

--- a/mm/memory.c~mm-oom-introduce-oom-reaper-fix-5-fix
+++ a/mm/memory.c
@@ -2414,7 +2414,7 @@ static inline void unmap_mapping_range_t
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows)
 {
-	struct zap_details details;
+	struct zap_details details = { };
 	pgoff_t hba = holebegin >> PAGE_SHIFT;
 	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
