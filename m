Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C81CC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:09:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03462206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:09:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="z113WwHc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03462206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EE406B026B; Mon, 10 Jun 2019 12:09:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6786F6B026D; Mon, 10 Jun 2019 12:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F0A06B026E; Mon, 10 Jun 2019 12:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14DBC6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:09:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t64so5442970pgt.8
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q/XqjsUkDq6xevue9zs57YIabmhhkQKl2VGDHiV5jq4=;
        b=qSGtXoU+EtB/oQbdoE72+Uo/mNmRoquCULdZROegfYtzq8rrst32gV5DXarY0iUHRN
         ySdldmsPqK2/hgRxwMl0BYgtO738icmpB6DBJwpxn2G+ysv/ZGNo7DCgBK5/1ZVwP2SN
         MsFYZNY+iQdKZggT8NlYaXN1VdiZHZnmooofs+K9+SXTQfgcKG0KFjNJQWEMCI6D8hUj
         C0w3kNTeQXqCnd8XW4b1TwwruSfwBT2+pjfwRPIq555Os+DMXBPwyXiqUg60EN5w3Ib4
         jYUVh5U18tAv/3KlGy+OH3YTefHpEqcUXXxKlbbMdExI7nYiCvtvSNLQyzr22qBGcWOs
         iOdQ==
X-Gm-Message-State: APjAAAUe0uPDoHs8OCBLrYTSutJetEsCmpXXZmhCaZggX4CwAf63oY6C
	+6TyWZkL2X3MJnM6DZjZFoaxO+g9qEsilflMpnMchIjIYspfHJXpRhD0L4Sshqq02q7US8oPgNn
	wmM76gjXzZ7PWLpXLKr5zW1SiP+hKDgRGG+daCDCyfgcQ2qKU7rhTgPogsZXvp7wBkw==
X-Received: by 2002:a62:e710:: with SMTP id s16mr40975531pfh.183.1560182979662;
        Mon, 10 Jun 2019 09:09:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJFwXjA2Wo1mtMyyUcCiBmrisrwjPrSQubKZVk95CqRx5wqK5A7J/qujWes4A2YK9xOKnS
X-Received: by 2002:a62:e710:: with SMTP id s16mr40975471pfh.183.1560182978993;
        Mon, 10 Jun 2019 09:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560182978; cv=none;
        d=google.com; s=arc-20160816;
        b=ZZIxKJqdFljTBuhWWRsTzaXkODC0omPCy7UX5JJYtrwqpDL7GqQJ5N42p3iNGql1Dl
         DWZqg521ONsveNjb63c/ZpiWvZf7Xe4xmSKO/zaw6dzjxC6O42Rnm4S4UccNHMpDXXim
         xNB9tD2vTOPcQtBsc4AwRctYGpKhz+13Q5wBc0MCJby4yAx79pHOvZIMHTmIsmaXKsOg
         DAbctkZkB/VGx4tJ48zBl05JF68EHxEV3CTGUGtcx7m+J0aR9+E9GopidvsG2M+gZYJb
         8apLdRQU/WpblKECeN+bzUgbq63MGNduxivFB0aBBQSibXhm1a3Q2vqwKDEw68LO6HD0
         TafA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q/XqjsUkDq6xevue9zs57YIabmhhkQKl2VGDHiV5jq4=;
        b=CSGj1kbTF+n100hDugETyufTSGnPcOdLmCWWgidisjVrSqv6KIDz9euVkl7Hdkahwr
         FeNvl5157X3+5XmY3hLlgZuSPfGNjAHU4M/9lDpDfvHneKTecGqsOnjq8iV6KqmXQ5Hx
         WSHPcHChHdGpu68NI/oKoZeE7ftTg6vPeTDtfGZc7S0xL7S8WIqQDBJuruC/MmDGh9jb
         /I5wa44ma+/m+YWmsKT/xaksGBDP1EVhGb1I/P3Y9BAUeEKUz/cb8LL6vk2F9IvD3iSE
         Vpm4JEBAu+miwZiJZ2r6vdCiqxMmd0uY3w2tAc1hgV8V+cc69izG21rx4loEP9OjZDnw
         kd0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z113WwHc;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r130si10042465pgr.509.2019.06.10.09.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:09:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z113WwHc;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5AG8dYb186787;
	Mon, 10 Jun 2019 16:09:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=q/XqjsUkDq6xevue9zs57YIabmhhkQKl2VGDHiV5jq4=;
 b=z113WwHcxX3n/yhODGaHV37Y8Y2xpZmcyhxxxXzJA/k/rxOYXjF2MjD/1uhcbfhftRYf
 5pqMjh5K3CtHPhzszPk3sJvtarblaJBFXn+SMzznHbGaB/24N8rQCO6FIzIJiYWF5Jmy
 0Ctn3AGwZpPxskUF74cndxv7urz5f3+PcDqCnsdci1pwvBGZZ6ksWHEShe2xXI4W3GG/
 zsFwGRTeohmYJJragnO65tWk+/TgIVgAHp17i7Qzmiy9ZuC84qzcwRNBXZbhGeO1dq1K
 Yw1OMGx7ZEqHS/69RztKNiTCeLKDWlHFChndJrLK17c0MsRVkQQFuAzKKwCH+BVYyVom Lg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2t04etfvt2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 16:09:37 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5AG9TMe154450;
	Mon, 10 Jun 2019 16:09:37 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2t024twpwf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 16:09:37 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5AG9aDJ022183;
	Mon, 10 Jun 2019 16:09:36 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 09:09:36 -0700
Date: Mon, 10 Jun 2019 09:09:34 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610160934.GH1871505@magnolia>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
 <20190610015145.GB3266@mit.edu>
 <20190610044144.GA1872750@magnolia>
 <20190610131417.GD15963@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610131417.GD15963@mit.edu>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906100110
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906100110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 09:14:17AM -0400, Theodore Ts'o wrote:
> On Sun, Jun 09, 2019 at 09:41:44PM -0700, Darrick J. Wong wrote:
> > On Sun, Jun 09, 2019 at 09:51:45PM -0400, Theodore Ts'o wrote:
> > > On Wed, Apr 17, 2019 at 12:04:33PM -0700, Darrick J. Wong wrote:
> >
> > > Shouldn't this check be moved before the modification of vmf->flags?
> > > It looks like do_page_mkwrite() isn't supposed to be returning with
> > > vmf->flags modified, lest "the caller gets surprised".
> > 
> > Yeah, I think that was a merge error during a rebase... :(
> > 
> > Er ... if you're still planning to take this patch through your tree,
> > can you move it to above the "vmf->flags = FAULT_FLAG_WRITE..." ?
> 
> I was planning on only taking 8/8 through the ext4 tree.  I also added
> a patch which filtered writes, truncates, and page_mkwrites (but not
> mmap) for immutable files at the ext4 level.

*Oh*.  I saw your reply attached to the 1/8 patch and thought that was
the one you were taking.  I was sort of surprised, tbh. :)

> I *could* take this patch through the mm/fs tree, but I wasn't sure
> what your plans were for the rest of the patch series, and it seemed
> like it hadn't gotten much review/attention from other fs or mm folks
> (well, I guess Brian Foster weighed in).

> What do you think?

Not sure.  The comments attached to the LWN story were sort of nasty,
and now that a couple of people said "Oh, well, Debian documented the
inconsistent behavior so just let it be" I haven't felt like
resurrecting the series for 5.3.

I do want to clean up the parameter validation for the VFS SETFLAGS and
FSSETXATTR ioctls though... eh, maybe I'll just send out the series as
it stands now.  I'm still maintaining it, so all that work might as well
go somewhere.

--D

> 
> 						- Ted
> 
> 
> 

