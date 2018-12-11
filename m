Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC1E8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:44:43 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so6670606edd.16
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:44:43 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si436922edc.252.2018.12.11.01.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 01:44:42 -0800 (PST)
Date: Tue, 11 Dec 2018 10:44:41 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: remove check with
 __highest_present_section_nr in for_each_present_section_nr()
Message-ID: <20181211094441.GD1286@dhcp22.suse.cz>
References: <20181211035128.43256-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211035128.43256-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de

On Tue 11-12-18 11:51:28, Wei Yang wrote:
> A valid present section number is in [0, __highest_present_section_nr].
> And the return value of next_present_section_nr() meets this
> requirement. This means it is not necessary to check it with
> __highest_present_section_nr again in for_each_present_section_nr().
> 
> Since we pass an unsigned long *section_nr* to
> for_each_present_section_nr(), we need to cast it to int before
> comparing.

Why do we want this patch? Is it an improvement? If yes, it is
performance visible change or does it make the code easier to maintain?

To me at least the later seems dubious to be honest because it adds a
non-obvious dependency of the terminal condition to the
next_present_section_nr implementation and that might turn out error
prone.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/sparse.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index a4fdbcb21514..9eaa8f98a3d2 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -197,8 +197,7 @@ static inline int next_present_section_nr(int section_nr)
>  }
>  #define for_each_present_section_nr(start, section_nr)		\
>  	for (section_nr = next_present_section_nr(start-1);	\
> -	     ((section_nr >= 0) &&				\
> -	      (section_nr <= __highest_present_section_nr));	\
> +	     (int)section_nr >= 0;				\
>  	     section_nr = next_present_section_nr(section_nr))
>  
>  static inline unsigned long first_present_section_nr(void)
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
