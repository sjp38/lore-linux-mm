Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8FA36B207A
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:34:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so1306058edt.23
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:34:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si633618edi.197.2018.11.20.06.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:34:23 -0800 (PST)
Date: Tue, 20 Nov 2018 15:34:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part
 of offlining
Message-ID: <20181120143422.GN22247@dhcp22.suse.cz>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-3-mhocko@kernel.org>
 <f25bfa30-96cf-799c-6885-86a3a537a977@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f25bfa30-96cf-799c-6885-86a3a537a977@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 20-11-18 15:26:43, David Hildenbrand wrote:
[...]
> > +	do {
> > +		for (pfn = start_pfn; pfn;)
> > +		{
> 
> { on a new line looks weird.
> 
> > +			/* start memory hot removal */
> > +			ret = -EINTR;
> 
> I think we can move that into the "if (signal_pending(current))"
> 
> (if my eyes are not wrong, this will not be touched otherwise)

Better?

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9cd161db3061..6bc3aee30f5e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1592,11 +1592,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	}
 
 	do {
-		for (pfn = start_pfn; pfn;)
-		{
+		for (pfn = start_pfn; pfn;) {
 			/* start memory hot removal */
-			ret = -EINTR;
 			if (signal_pending(current)) {
+				ret = -EINTR;
 				reason = "signal backoff";
 				goto failed_removal_isolated;
 			}
-- 
Michal Hocko
SUSE Labs
