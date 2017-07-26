Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9051C6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:21:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a2so224748028pgn.15
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:21:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k4si7919512pgr.0.2017.07.26.12.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:21:10 -0700 (PDT)
Date: Wed, 26 Jul 2017 12:21:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 4/4] gfs2: convert to errseq_t based writeback error
 reporting for fsync
Message-ID: <20170726192105.GD15980@bombadil.infradead.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-5-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726175538.13885-5-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed, Jul 26, 2017 at 01:55:38PM -0400, Jeff Layton wrote:
> @@ -668,12 +668,14 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
>  		if (ret)
>  			return ret;
>  		if (gfs2_is_jdata(ip))
> -			filemap_write_and_wait(mapping);
> +			ret = file_write_and_wait(file);
> +		if (ret)
> +			return ret;
>  		gfs2_ail_flush(ip->i_gl, 1);
>  	}

Do we want to skip flushing the AIL if there was an error (possibly
previously encountered)?  I'd think we'd want to flush the AIL then report
the error, like this:

 		if (gfs2_is_jdata(ip))
-			filemap_write_and_wait(mapping);
+			ret = file_write_and_wait(file);
 		gfs2_ail_flush(ip->i_gl, 1);
+		if (ret)
+			return ret;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
