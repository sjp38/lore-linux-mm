Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 145156B00D7
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 18:46:40 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id u7so1537948qaz.25
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 15:46:39 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v5 7/7] fs: add a flag for per-operation O_DSYNC semantics
References: <cover.1415220890.git.milosz@adfin.com>
	<cover.1415220890.git.milosz@adfin.com>
	<c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
Date: Thu, 06 Nov 2014 18:46:08 -0500
In-Reply-To: <c188b04ede700ce5f986b19de12fa617d158540f.1415220890.git.milosz@adfin.com>
	(Milosz Tanski's message of "Wed, 5 Nov 2014 16:14:53 -0500")
Message-ID: <x49r3xf28qn.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Mel Gorman <mgorman@suse.de>, Volker Lendecke <Volker.Lendecke@sernet.de>, Tejun Heo <tj@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, linux-api@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-arch@vger.kernel.org, ceph-devel@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org

Milosz Tanski <milosz@adfin.com> writes:

> -		if (type == READ && (flags & RWF_NONBLOCK))
> -			return -EAGAIN;
> +		if (type == READ) {
> +			if (flags & RWF_NONBLOCK)
> +				return -EAGAIN;
> +		} else {
> +			if (flags & RWF_DSYNC)
> +				return -EINVAL;
> +		}

Minor nit, but I'd rather read something that looks like this:

	if (type == READ && (flags & RWF_NONBLOCK))
		return -EAGAIN;
	else if (type == WRITE && (flags & RWF_DSYNC))
		return -EINVAL;

I won't lose sleep over it, though.

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
