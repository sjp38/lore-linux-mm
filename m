Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FC7C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:15:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CFE72173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:15:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qQ0vpRj8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CFE72173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9D478E0003; Tue, 26 Feb 2019 11:15:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4DED8E0001; Tue, 26 Feb 2019 11:15:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEFFD8E0003; Tue, 26 Feb 2019 11:15:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BC068E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:15:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g197so10826798pfb.15
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:15:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PFOmNSXERoShH2nRHfdwWjGkF5WH9Hmxoe3env79QL0=;
        b=K56kQ0ISL+yE87MieQfHymJXJY9HZkQmCW4g77uMNunkPyu6o0cOydd5s6x6wR7kez
         iFWmN04d0SahJ5B5tsBWGQ1cJLsUbe7I3eHV02ySNo4ngF7NL7NhucC7uWDMjwQnIAnn
         +N5M3H2JBjfUuzX5MXmJQvNGJmv1fpYJVoBoVj5br5Tx+B1ndvVd4pKLDTdUPs4F4rHC
         dzoIQLi5k10/bNeuhEGR/s0dkUGu2tz+UnX70WgORG3O6skmaIrYzKnZMwajY94XMfnS
         26mUx6MIyh9xlxZk+fnnkuzCJ+h0GJu0JtnngVljqtAMGBDKxI92DSiwIrcLDLZwo2jm
         fGZQ==
X-Gm-Message-State: AHQUAuY27Ovsiw2TMLn4XG8yxWD1DXTCbv+AN+8QZGY/6aWNQQyx7uCg
	iwfK6YwsZBQjfPk3z+M+2MTBRTtNFmZqqPlGg4vVuDPfCnEKemNtbbxUieobPV1VJM9nIskDX3x
	lshcrFp46fGSybgpz41wCPFstLChdme38x4KWrKQNT6G6Hi7+SZwrZvH45PpwDuJsCg==
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr27509659pls.178.1551197708069;
        Tue, 26 Feb 2019 08:15:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVM6aIRZ0uSQlMSC8FSYQtoLUGZlXf/eeTTuKGT2w0boErMu3na+gCbiBMRx4lH0QhzQEd
X-Received: by 2002:a17:902:b70b:: with SMTP id d11mr27509536pls.178.1551197706562;
        Tue, 26 Feb 2019 08:15:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551197706; cv=none;
        d=google.com; s=arc-20160816;
        b=sPYPBmGTdSi/PwTxwBTEN7FoWa/L43qC/JqoAiS2beiiUmRxIulp+4udJOoctBvkDX
         W/WGDYsSxhhBRLpjMe7A0H3BHx+dq2D7wuc+UXrj7dIt9IAhOIEO1wgkAa464hFPoh0c
         91BBEORvopCk3iMMcOidRgKF9tdwMj1wNSnQTVtV3eFQl14xj6HkvH1xifDJv9uisPgo
         zhpLI43X/b2/xbEsPRIbO7+wy/n9FZm2VwhMzbJCd+XAtEyVMPQXpX2CWOikewLJBsK7
         8qhaZTxTbhoGXWUfrYnGot6zkMyRuWxA7T7U4P+Hx3Pet6w17/P/H9T0aP8/GAU3K8+X
         eNmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PFOmNSXERoShH2nRHfdwWjGkF5WH9Hmxoe3env79QL0=;
        b=cJ76szNJvzKLxF3vcUxAIeuKf91773he71noAycRTAkNjOmHoRET5cefz0aFFopYts
         IXUb3P7w61hecOtLbtA3t1o8AQuYJ0Zj8PwMOWKf8ZLbYd0zjpKyTGP9m37t0wWXoLW2
         SGThJBKG2mJZaiyitbgcEnzFgnln2z8kv8YigdqX0McYIXykgroj00KUn86QnvLVQcwb
         0Aclu6ZhRypT8fortuHEhKt4O3V9jNk8uTCAr3OqT8O8JoFhR+stcIwbXkP31QCEiDVK
         nC64C9z5kfGeQ2zd+SSqQ87NydsMUHbIO47yrWip2g3+0sCVXOtZ0fudOkPU+P0l1zoI
         24yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qQ0vpRj8;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p18si13113724plq.130.2019.02.26.08.15.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 08:15:06 -0800 (PST)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qQ0vpRj8;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1QGCqAC033528;
	Tue, 26 Feb 2019 16:14:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=PFOmNSXERoShH2nRHfdwWjGkF5WH9Hmxoe3env79QL0=;
 b=qQ0vpRj814sZq4kSa2WnFuCwals7O5fdfQAPqvcNMDj08ztBMyjbjb+BwfnTGRKfZbtu
 Rro5ouRnSmoXOma1SJ1HJ9yfnxI87fYvtj4I7ancivEccqcMzfFOIIJ6GLb0+FX9qrDi
 4LudWZ0isLmxxCc7KzCyPhjKYypp4mTLikbNeAKFGi9NU8Dq0+KVBFOAE9Mx19qKb/WX
 u2ZW3gNfCjrFvPymOS7ol6IZ8FORYt2fU1fL1jUXzDDiwzKNufvEAIudXZRR83+aPzoE
 BxaY64pR+a3YClDr/rFn6+YDvbDJTZOhAmhvX8tI4fFRGltPR8AT7M4GaFUA4QvhRz4Q 5A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2qtwku5m91-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 16:14:46 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1QGEeUj005011
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 16:14:40 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1QGEckn024347;
	Tue, 26 Feb 2019 16:14:39 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Feb 2019 08:14:38 -0800
Date: Tue, 26 Feb 2019 08:14:33 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ming Lei <ming.lei@redhat.com>, Ming Lei <tom.leiming@gmail.com>,
        Vlastimil Babka <vbabka@suse.cz>, Dave Chinner <david@fromorbit.com>,
        "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
        Jens Axboe <axboe@kernel.dk>, Vitaly Kuznetsov <vkuznets@redhat.com>,
        Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        linux-block <linux-block@vger.kernel.org>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226161433.GH21626@magnolia>
References: <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
 <20190226134247.GA30942@ming.t460p>
 <20190226140440.GF11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226140440.GF11592@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9178 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902260115
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 06:04:40AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 09:42:48PM +0800, Ming Lei wrote:
> > On Tue, Feb 26, 2019 at 05:02:30AM -0800, Matthew Wilcox wrote:
> > > Wait, we're imposing a ridiculous amount of complexity on XFS for no
> > > reason at all?  We should just change this to 512-byte alignment.  Tying
> > > it to the blocksize of the device never made any sense.
> > 
> > OK, that is fine since we can fallback to buffered IO for loop in case of
> > unaligned dio.
> > 
> > Then something like the following patch should work for all fs, could
> > anyone comment on this approach?
> 
> That's not even close to what I meant.
> 
> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index ec2fb6fe6d37..dee1fc47a7fc 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -1185,18 +1185,20 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,

Wait a minute, are you all saying that /directio/ is broken on XFS too??
XFS doesn't use blockdev_direct_IO anymore.

I thought we were talking about alignment of XFS metadata buffers
(xfs_buf.c), which is a very different topic.

As I understand the problem, in non-debug mode the slab caches give
xfs_buf chunks of memory that are aligned well enough to work, but in
debug mode the slabs allocate slightly more bytes to carry debug
information which pushes the returned address up slightly, thus breaking
the alignment requirements.

So why can't we just move the debug info to the end of the object?  If
our 512 byte allocation turns into a (512 + a few more) bytes we'll end
up using 1024 bytes on the allocation regardless, so it shouldn't matter
to put the debug info at offset 512.  If the reason is fear that kernel
code will scribble off the end of the object, then return (*obj + 512).
Maybe you all have already covered this, though?

--D

>  	struct dio_submit sdio = { 0, };
>  	struct buffer_head map_bh = { 0, };
>  	struct blk_plug plug;
> -	unsigned long align = offset | iov_iter_alignment(iter);
>  
>  	/*
>  	 * Avoid references to bdev if not absolutely needed to give
>  	 * the early prefetch in the caller enough time.
>  	 */
>  
> -	if (align & blocksize_mask) {
> +	if (iov_iter_alignment(iter) & 511)
> +		goto out;
> +
> +	if (offset & blocksize_mask) {
>  		if (bdev)
>  			blkbits = blksize_bits(bdev_logical_block_size(bdev));
>  		blocksize_mask = (1 << blkbits) - 1;
> -		if (align & blocksize_mask)
> +		if (offset & blocksize_mask)
>  			goto out;
>  	}
>  

