Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 086E46B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:56:44 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id js8so40209660lbc.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:56:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si1596537wmd.46.2016.06.17.05.56.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 05:56:42 -0700 (PDT)
Subject: Re: [PATCH v3 5/9] tools/vm/page_owner: increase temporary buffer
 size
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1466150259-27727-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8ddf2808-75ab-df5e-e2c1-b48ced7f60f5@suse.cz>
Date: Fri, 17 Jun 2016 14:56:40 +0200
MIME-Version: 1.0
In-Reply-To: <1466150259-27727-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 06/17/2016 09:57 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Page owner will be changed to store more deep stacktrace so current
> temporary buffer size isn't enough.  Increase it.
>
> Link: http://lkml.kernel.org/r/1464230275-25791-5-git-send-email-iamjoonsoo.kim@lge.com
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  tools/vm/page_owner_sort.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/tools/vm/page_owner_sort.c b/tools/vm/page_owner_sort.c
> index 77147b4..f1c055f 100644
> --- a/tools/vm/page_owner_sort.c
> +++ b/tools/vm/page_owner_sort.c
> @@ -79,12 +79,12 @@ static void add_list(char *buf, int len)
>  	}
>  }
>
> -#define BUF_SIZE	1024
> +#define BUF_SIZE	(128 * 1024)
>
>  int main(int argc, char **argv)
>  {
>  	FILE *fin, *fout;
> -	char buf[BUF_SIZE];
> +	char *buf;
>  	int ret, i, count;
>  	struct block_list *list2;
>  	struct stat st;
> @@ -107,6 +107,11 @@ int main(int argc, char **argv)
>  	max_size = st.st_size / 100; /* hack ... */
>
>  	list = malloc(max_size * sizeof(*list));
> +	buf = malloc(BUF_SIZE);
> +	if (!list || !buf) {
> +		printf("Out of memory\n");
> +		exit(1);
> +	}
>
>  	for ( ; ; ) {
>  		ret = read_block(buf, BUF_SIZE, fin);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
