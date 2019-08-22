Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D45FEC3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:05:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B06AD233FE
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:05:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B06AD233FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51D9D6B02D1; Thu, 22 Aug 2019 03:05:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CD7F6B02D2; Thu, 22 Aug 2019 03:05:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E3016B02D3; Thu, 22 Aug 2019 03:05:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0202.hostedemail.com [216.40.44.202])
	by kanga.kvack.org (Postfix) with ESMTP id 16BB36B02D1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:05:54 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7A8F38E74
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:05:53 +0000 (UTC)
X-FDA: 75849178986.27.heat58_507e7053b9b37
X-HE-Tag: heat58_507e7053b9b37
X-Filterd-Recvd-Size: 2164
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:05:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A338EAE00;
	Thu, 22 Aug 2019 07:05:51 +0000 (UTC)
Date: Thu, 22 Aug 2019 09:05:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yizhuo <yzhai003@ucr.edu>
Cc: csong@cs.ucr.edu, zhiyunq@cs.ucr.edu,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/memcg: return value of the function
 mem_cgroup_from_css() is not checked
Message-ID: <20190822070550.GA12785@dhcp22.suse.cz>
References: <20190822062210.18649-1-yzhai003@ucr.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822062210.18649-1-yzhai003@ucr.edu>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 23:22:09, Yizhuo wrote:
> Inside function mem_cgroup_wb_domain(), the pointer memcg
> could be NULL via mem_cgroup_from_css(). However, this pointer is
> not checked and directly dereferenced in the if statement,
> which is potentially unsafe.

Could you describe circumstances when this would happen? The code is
this way for 5 years without any issues. Are we just lucky or something
has changed recently to make this happen?
 
> Signed-off-by: Yizhuo <yzhai003@ucr.edu>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 661f046ad318..bd84bdaed3b0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3665,7 +3665,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
>  
> -	if (!memcg->css.parent)
> +	if (!memcg || !memcg->css.parent)
>  		return NULL;
>  
>  	return &memcg->cgwb_domain;
> -- 
> 2.17.1
> 

-- 
Michal Hocko
SUSE Labs

