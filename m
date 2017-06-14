Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 134026B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 01:59:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 56so35865451wrx.5
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 22:59:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si2270075wra.150.2017.06.13.22.59.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 22:59:27 -0700 (PDT)
Date: Wed, 14 Jun 2017 07:59:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH] base/memory: pass the base_section in
 add_memory_block
Message-ID: <20170614055925.GA6045@dhcp22.suse.cz>
References: <20170614054550.14469-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614054550.14469-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 14-06-17 13:45:50, Wei Yang wrote:
> Based on Greg's comment, cc it to mm list.
> The original thread could be found https://lkml.org/lkml/2017/6/7/202

I have already given you feedback
http://lkml.kernel.org/r/20170613114842.GI10819@dhcp22.suse.cz
and you seemed to ignore it completely.

> The second parameter of init_memory_block() is used to calculate the
> start_section_nr of this block, which means any section in the same block
> would get the same start_section_nr.
> 
> This patch passes the base_section to init_memory_block(), so that to
> reduce a local variable and a check in every loop.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  drivers/base/memory.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index cc4f1d0cbffe..1e903aba2aa1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -664,21 +664,20 @@ static int init_memory_block(struct memory_block **memory,
>  static int add_memory_block(int base_section_nr)
>  {
>  	struct memory_block *mem;
> -	int i, ret, section_count = 0, section_nr;
> +	int i, ret, section_count = 0;
>  
>  	for (i = base_section_nr;
>  	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
>  	     i++) {
>  		if (!present_section_nr(i))
>  			continue;
> -		if (section_count == 0)
> -			section_nr = i;
>  		section_count++;
>  	}
>  
>  	if (section_count == 0)
>  		return 0;
> -	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
> +	ret = init_memory_block(&mem, __nr_to_section(base_section_nr),
> +				MEM_ONLINE);
>  	if (ret)
>  		return ret;
>  	mem->section_count = section_count;
> -- 
> 2.11.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
