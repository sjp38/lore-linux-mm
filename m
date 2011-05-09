Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 005726B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 04:24:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 29C9D3EE0BC
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:24:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0A5245DF4A
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:24:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D092645DF48
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:24:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1CCE18004
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:24:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 826F91DB803B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 17:24:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] proc: allocate storage for numa_maps statistics once
In-Reply-To: <1303947349-3620-9-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-9-git-send-email-wilsons@start.ca>
Message-Id: <20110509172613.166B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 17:24:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>  static int numa_maps_open(struct inode *inode, struct file *file)
>  {
> -	return do_maps_open(inode, file, &proc_pid_numa_maps_op);
> +	struct numa_maps_private *priv;
> +	int ret = -ENOMEM;
> +	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +	if (priv) {
> +		priv->proc_maps.pid = proc_pid(inode);
> +		ret = seq_open(file, &proc_pid_numa_maps_op);
> +		if (!ret) {
> +			struct seq_file *m = file->private_data;
> +			m->private = priv;
> +		} else {
> +			kfree(priv);
> +		}
> +	}
> +	return ret;
>  }

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
