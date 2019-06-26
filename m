Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E700CC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:31:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A76A52133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:31:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="N/a93ebu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A76A52133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F228E0003; Wed, 26 Jun 2019 12:31:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34F908E0002; Wed, 26 Jun 2019 12:31:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23EB58E0003; Wed, 26 Jun 2019 12:31:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 026EE8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:31:04 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id j77so658009vsd.3
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:31:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Mz7em8B5BcTHywkzCrR8lugIdy2ootcWo4w3RRWBYaM=;
        b=kcK5+cqrDqMZgVFG2+DhohN+BA8lK4oHLgrLNmrGoxKHMrvSYBbmtyrG6Hiab90isy
         AY9dWiXUdtoEbJfkxHQO68skYoaBeAqYWGpaD5AjMvmRLoE5Ux55D8byY6CsAU/LwmRJ
         PnohAWkoUpwLdZiX+SPv+vGFpgDreEEG0EOxLwbX+OHtUQW4R5uq5GDgCMMHgpM01HS8
         /4bYRaPAIqw9tu9QIbBOqGjHxZCm2jBdH8iGGBZBvURx8ldR2UxWh4IPDYyYvQ5yYgpq
         re6wngHOcYCNWNKNrmBA9Nk6atqeW26yI93fXG2bR220G8KdaB//FLrz3sen3jOjZOPk
         lptQ==
X-Gm-Message-State: APjAAAVrcVVqP3uaBobanTq1X8Nxw51AFP6nPzWDTJja1NAgqwXOeVoY
	GXp+4f/gFVkFqvZz5zoBzewR3jRyVHTXIdNsVMF8LpMzBwPjIPiKnnrgI+C0t4ZBJk6o6SsdZfC
	j3rBImu0nZa0WyzrCf8EI3X4osoN+5XXm8nUKE3RNFdeXlCFB6HWgUOTXXUdyXm8Qiw==
X-Received: by 2002:ab0:74c9:: with SMTP id f9mr3175786uaq.18.1561566663659;
        Wed, 26 Jun 2019 09:31:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybZZZ6hKP+bhSBt/Uc/GhR7kUuYpw58bUsg12N34UKj5H54SMhRdIIUN6jAzXOATezUF0I
X-Received: by 2002:ab0:74c9:: with SMTP id f9mr3175721uaq.18.1561566662690;
        Wed, 26 Jun 2019 09:31:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561566662; cv=none;
        d=google.com; s=arc-20160816;
        b=sgyrXkgNl7JPFGh7HNnsf2CNhs34awskBI7Vw9oztcuJxwJES9fEjWBAuoikKLKny8
         Q4C9cWQvnLWa/8bEK1xPGlX3vqVPgpJMoeX00CikPib02EUntUo3Nyd957lN/MMxfyAK
         ui7iczqGJJSsolZVgeImWkkqILo5zWeGBzeWCs10AL9RV47HkVIJ8mCk5Hs8ThdoSJhT
         nf3+rNtDQd0Sf0Q3vHl/xmEtR6GixYRze+DHx+4xzpPY270u4VHxraTN0yH6htPOzDVh
         skCUtWK7NhU1WAT2nO6wSiVZO61hWWTAKoq5xqX67CAv44CPka08wxBORPrEQIPw2z9Y
         NoYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Mz7em8B5BcTHywkzCrR8lugIdy2ootcWo4w3RRWBYaM=;
        b=NPR7/NxPxkTqQPBsiL02ilaN0CPbfASoFMruzwR9FUbyvjK//m0aQdAcRRN6vq10M6
         Dvm2fnxX69aijUl2QtKRZUdku7P1f8gqA4oCS6S+p4m0H/VCGu8CD1QBhhiEhyre45Vo
         2CGeF8m8PP8sClaG7IItTSVw3BZlS4ISZqBeoUp+BseuGQHgBAsZ//i9ikgIX5ve5FLz
         KkKePhyONq5dyZLgMdTe5Z9MoLUwmdbSkBVVvxvYFGnoFdcmmR24LJMMIqGz/bDws4aY
         misee276Kfh1pStPRqY4uOqdcWYhfEdLtpSgTVNML9QNi/O6109rwjry1qLXVNeyR0tw
         A0GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="N/a93ebu";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f13si1186057vsm.173.2019.06.26.09.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 09:31:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="N/a93ebu";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5QGU4Wg004218;
	Wed, 26 Jun 2019 16:30:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Mz7em8B5BcTHywkzCrR8lugIdy2ootcWo4w3RRWBYaM=;
 b=N/a93ebuSSKM+1UIO0buPOjR9AvCbLsHhw01AwBMp/XW9BUb98JLnzoJbLgwOZFWmGyw
 hJdpkR7HkvPCAWlWLDnQsdQatbUdssqmn37SwPrTcAyE+/9x/iin4aJ6YtVFtP1GNmmr
 W4gQLbQG2SBcdOy5QNpDSE2/3fIVqQVrn7mZXub6KhldCj8Zzx/yQQ7a5EH7pzSZXmup
 IrJvp7zWK9kXgRoeoC8dGqS2tKAzLiR74Ta5S5LQWYLQBZWpbM10fUskgAys8/96vQdr
 G26RY/thy8CrA4lCa0mPtRoigi2YSG7nQksiKL4VCeGiPZV6yAFAimBMe+B5DQlWGUUd ig== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t9brtbf85-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 16:30:39 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5QGRxdd192423;
	Wed, 26 Jun 2019 16:28:38 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t9p6uvctr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 26 Jun 2019 16:28:38 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5QGScxQ193859;
	Wed, 26 Jun 2019 16:28:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2t9p6uvctj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 16:28:38 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5QGSZWS032167;
	Wed, 26 Jun 2019 16:28:35 GMT
Received: from localhost (/10.159.137.246)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 26 Jun 2019 09:28:35 -0700
Date: Wed, 26 Jun 2019 09:28:31 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        ard.biesheuvel@linaro.org, josef@toxicpanda.com, hch@infradead.org,
        clm@fb.com, adilger.kernel@dilger.ca, jack@suse.com, dsterba@suse.com,
        jaegeuk@kernel.org, jk@ozlabs.org, reiserfs-devel@vger.kernel.org,
        linux-efi@vger.kernel.org, devel@lists.orangefs.org,
        linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-nilfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        ocfs2-devel@oss.oracle.com, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 5/5] vfs: don't allow writes to swap files
Message-ID: <20190626162831.GF5171@magnolia>
References: <156151637248.2283603.8458727861336380714.stgit@magnolia>
 <156151641177.2283603.7806026378321236401.stgit@magnolia>
 <20190626035151.GA10613@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626035151.GA10613@ZenIV.linux.org.uk>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9300 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260193
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 04:51:51AM +0100, Al Viro wrote:
> On Tue, Jun 25, 2019 at 07:33:31PM -0700, Darrick J. Wong wrote:
> > --- a/fs/attr.c
> > +++ b/fs/attr.c
> > @@ -236,6 +236,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr, struct inode **de
> >  	if (IS_IMMUTABLE(inode))
> >  		return -EPERM;
> >  
> > +	if (IS_SWAPFILE(inode))
> > +		return -ETXTBSY;
> > +
> >  	if ((ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) &&
> >  	    IS_APPEND(inode))
> >  		return -EPERM;
> 
> Er...  So why exactly is e.g. chmod(2) forbidden for swapfiles?  Or touch(1),
> for that matter...

Oops, that check is overly broad; I think the only attribute change we
need to filter here is ATTR_SIZE.... which we could do unconditionally
in inode_newsize_ok.

What's the use case for allowing userspace to increase the size of an
active swapfile?  I don't see any; the kernel has a permanent lease on
the file space mapping (at least until swapoff)...

> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 596ac98051c5..1ca4ee8c2d60 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -3165,6 +3165,19 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
> >  	if (error)
> >  		goto bad_swap;
> >  
> > +	/*
> > +	 * Flush any pending IO and dirty mappings before we start using this
> > +	 * swap file.
> > +	 */
> > +	if (S_ISREG(inode->i_mode)) {
> > +		inode->i_flags |= S_SWAPFILE;
> > +		error = inode_drain_writes(inode);
> > +		if (error) {
> > +			inode->i_flags &= ~S_SWAPFILE;
> > +			goto bad_swap;
> > +		}
> > +	}
> 
> Why are swap partitions any less worthy of protection?

Hmm, yeah, S_SWAPFILE should apply to block devices too.  I figured that
the mantra of "sane tools will open block devices with O_EXCL" should
have sufficed, but there's really no reason to allow that either.

--D

