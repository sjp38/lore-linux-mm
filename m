Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63BDA6B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 16:21:16 -0400 (EDT)
Date: Fri, 5 Jun 2009 13:20:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH mmotm] memcg: add interface to reset limits
Message-Id: <20090605132031.02f79021.akpm@linux-foundation.org>
In-Reply-To: <20090605222245.6920061a.d-nishimura@mtf.biglobe.ne.jp>
References: <20090603114518.301cef4d.nishimura@mxp.nes.nec.co.jp>
	<20090603114908.52c3aed5.nishimura@mxp.nes.nec.co.jp>
	<4A26072B.8040207@cn.fujitsu.com>
	<20090603144347.81ec2ce1.nishimura@mxp.nes.nec.co.jp>
	<20090605222245.6920061a.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: d-nishimura@mtf.biglobe.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lizf@cn.fujitsu.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009 22:22:45 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> We don't have interface to reset mem.limit or memsw.limit now.
> 
> This patch allows to reset mem.limit or memsw.limit when they are
> being set to -1.
> 
> ...
>
> @@ -133,6 +133,16 @@ int res_counter_memparse_write_strategy(const char *buf,
>  					unsigned long long *res)
>  {
>  	char *end;
> +
> +	/* return RESOURCE_MAX(unlimited) if "-1" is specified */
> +	if (*buf == '-') {
> +		*res = simple_strtoull(buf + 1, &end, 10);
> +		if (*res != 1 || *end != '\0')
> +			return -EINVAL;
> +		*res = RESOURCE_MAX;
> +		return 0;
> +	}

The test for (*end != '\0') would be unneeded if strict_strtoull() had
been used.


> +
>  	/* FIXME - make memparse() take const char* args */
>  	*res = memparse((char *)buf, &end);
>  	if (*end != '\0')

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
