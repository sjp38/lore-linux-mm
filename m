Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id B2D506B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 06:06:39 -0500 (EST)
Message-ID: <50D2F142.401@parallels.com>
Date: Thu, 20 Dec 2012 15:06:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/19] shrinker: convert superblock shrinkers to new API
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-6-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-6-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On 11/28/2012 03:14 AM, Dave Chinner wrote:
> +static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct super_block *sb;
> +	long	total_objects = 0;
> +
> +	sb = container_of(shrink, struct super_block, s_shrink);
> +
> +	if (!grab_super_passive(sb))
> +		return -1;
> +


You're missing the GFP_FS check here. This leads to us doing all the
counting only to find out later, in the scanner, that we won't be able
to free it. Better exit early.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
