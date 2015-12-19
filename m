Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8644402ED
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 14:52:41 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l126so24699463wml.1
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 11:52:41 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id x192si22632564wme.77.2015.12.19.11.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Dec 2015 11:52:40 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id l126so24553621wml.1
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 11:52:39 -0800 (PST)
Date: Sat, 19 Dec 2015 21:52:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, oom: initiallize all new zap_details fields before
 use
Message-ID: <20151219195237.GA31380@node.shutemov.name>
References: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 18, 2015 at 08:04:51PM -0500, Sasha Levin wrote:
> Commit "mm, oom: introduce oom reaper" forgot to initialize the two new fields
> of struct zap_details in unmap_mapping_range(). This caused using stack garbage
> on the call to unmap_mapping_range_tree().
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/memory.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 206c8cd..0e32993 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2431,6 +2431,7 @@ void unmap_mapping_range(struct address_space *mapping,
>  	details.last_index = hba + hlen - 1;
>  	if (details.last_index < details.first_index)
>  		details.last_index = ULONG_MAX;
> +	details.check_swap_entries = details.ignore_dirty = false;

Should we use c99 initializer instead to make it future-proof?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
