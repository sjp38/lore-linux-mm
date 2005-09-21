Date: Wed, 21 Sep 2005 12:10:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/4] hugetlbfs: move free_inodes accounting
Message-Id: <20050921121036.416bdbfb.akpm@osdl.org>
In-Reply-To: <20050921092156.GA22544@lst.de>
References: <20050921092156.GA22544@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: viro@ftp.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@lst.de> wrote:
>
> +static inline int hugetlbfs_inc_free_inodes(struct hugetlbfs_sb_info *sbinfo)
>  +{
>  +	if (sbinfo->free_inodes >= 0) {
>  +		spin_lock(&sbinfo->stat_lock);
>  +		if (unlikely(!sbinfo->free_inodes)) {
>  +			spin_unlock(&sbinfo->stat_lock);
>  +			return 0;
>  +		}
>  +		sbinfo->free_inodes--;
>  +		spin_unlock(&sbinfo->stat_lock);
>  +	}
>  +
>  +	return 1;
>  +}
>  +
>  +static void hugetlbfs_dec_free_inodes(struct hugetlbfs_sb_info *sbinfo)
>  +{
>  +	if (sbinfo->free_inodes >= 0) {
>  +		spin_lock(&sbinfo->stat_lock);
>  +		sbinfo->free_inodes++;
>  +		spin_unlock(&sbinfo->stat_lock);
>  +	}
>  +}
>  +


These functions seem to be called from the right places, but the naming is
most confusing.

The test for the current value of sbinfo->free_inodes in
hugetlbfs_dec_free_inodes() looks racy and the logic simply escapes me. 
Does anyone remember why we have special-case handling in there for
(sbinfo->free_inodes < 0)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
