Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D2EDC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:37:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5532F208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 20:37:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="i0tlux+8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5532F208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dilger.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E20596B0003; Tue, 25 Jun 2019 16:37:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9A68E0003; Tue, 25 Jun 2019 16:37:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C71378E0002; Tue, 25 Jun 2019 16:37:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFDC6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 16:37:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so53990pfc.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 13:37:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:message-id:mime-version
         :subject:date:in-reply-to:cc:to:references;
        bh=k9wVBI3MNSxJVQhODLuSRbOf+SmT1l1K5RRF5+DdhGM=;
        b=jXZvTo8tDgHUHE7yzWYaQ3QN6QIqs6779MRECETXM7pCNiBaLbsOJPim91rmxvqJWZ
         rBVYuQehWheWLQ0Rqxz0CIo2v/Nceko2zPPQrH8oQj/05In/eXv+4EIA5qbYuNMIpPKW
         bIvnuLMyfJ0f97O8wWnCTRIZaZI3QqlYIeegg6b0UgjzgbVLsdvba1Ruq+FkbBjLEd5z
         TPWb5lCjNPGPJxdShyD2PCycZ0wJ5GxXtxy5lLuwvKpnq8TT1qGA5zAd3IV5Wryuej0M
         0LKpzt1AAMJb79aH1EDzZaaOaEDTFMSr1nNc8eyebBt+2VvfuQ098U9fAiqnHEd4OnhW
         YXjg==
X-Gm-Message-State: APjAAAV0qKZReOCxKwpz3ZYy5ci0R3UPok7mgDDWjbCYli6ukH8bqXrB
	zgYr6zC4ax9C3TvKi8x2dQPljaHWssew7SO4B0hKZYFAaMG//GD8ZHKHeVeT7FiDUKhSXtZU3Y4
	4AdPdx2zpl40ceru8VoOuGtC8NDYRUd/JcfyA6LEmrzq1ZihJ4By31Ey95m4M9kMw+Q==
X-Received: by 2002:a63:8043:: with SMTP id j64mr25425957pgd.216.1561495064115;
        Tue, 25 Jun 2019 13:37:44 -0700 (PDT)
X-Received: by 2002:a63:8043:: with SMTP id j64mr25425904pgd.216.1561495063098;
        Tue, 25 Jun 2019 13:37:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561495063; cv=none;
        d=google.com; s=arc-20160816;
        b=X/SJGHVV4RRvTqOFI565q+0gpsYPYjtkYKkV+5tlxhJwwwkr8t6HaLRWbMTYuFYRJh
         5UCaoBxKK9Ws61V00qaYotlbWeFWWjZ/i87lUutnPCJoKmSXWzVWwrlli3wHHe7vH+cR
         9YST+lIHpGokzOXu+oqsHQI1BAubYcDW1LSlEQw9iypReaME8foEOKvLYBsyga3b8+38
         L+fHEeKe2Jt2l5UqpQc9wWmUK2n+jh2MpWGWyhb1VXBvrGMz8Y2Pt+Aqmt+liBsKt0jj
         9v0q4SEE0K3NI9bmFtG7+ly+Pys2Wuwm03HJ1xQk2WkNhc9ryEDQk25XDFjoj+5Q8m9M
         VR3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:to:cc:in-reply-to:date:subject:mime-version:message-id
         :from:dkim-signature;
        bh=k9wVBI3MNSxJVQhODLuSRbOf+SmT1l1K5RRF5+DdhGM=;
        b=ayJmH04SiQYBNr+eg92tPiECxns/iOS+FQ38WE9+GxVEU0xulB0IV+bYQhJDG2sefn
         Hbsc/INGW44LbzzkXvjd6d2dJnCSTWUgX/KWLkMHxt+j3imvGvUH/IupAhmpcTYsk80G
         5VwQWG09Xp8N870XNZ7otWfKKW4QSZcXAWgbG0vDvP8n1WO6ihNvz+LaXTnA7auayCk0
         BN9GUg0gSItADSZ7I919UGYlxpwBnLb0R3xSYTUprv90b67ybbJGEWasSS6HrjdR+8ys
         d4+AbWnfAo4x4TI8SBF3rvd746bZh0bgUnD2QPFXvu5oa9hrfCZ00YTDX4eXLY6JF+Pv
         iYKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b=i0tlux+8;
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor18090023plo.54.2019.06.25.13.37.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 13:37:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@dilger-ca.20150623.gappssmtp.com header.s=20150623 header.b=i0tlux+8;
       spf=pass (google.com: domain of adilger@dilger.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=adilger@dilger.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=k9wVBI3MNSxJVQhODLuSRbOf+SmT1l1K5RRF5+DdhGM=;
        b=i0tlux+8FNEu0ugkEvUUlD4zKy+jo4LmPTngoA6r4KZwHDBk4l5v9aHPUQEnX49/5g
         z/5lU03hiGUesQ1zP/lPDO/M9fU515Y8oNEl0EKjwdC7dNyZmZQEQEJzGU548pSrAizw
         AlBCGdOUNg8gVK9FeesIiFWJzJ6YbgT5nrsBvzAUmh99yf7q8hQlgwIm8HPdOmToZugA
         nEmrM6blVwgyo7dN5eFPje1f1HwAtA+5XwodCP1ntkD5mvR/FwjSqB5AJn7YMTtfEeor
         5bhYLcubsCaGOlgF0onarHD40ER7JyKcO4a/eslTTHQKCN3GB1Tra4WgBV7T6KYa0chE
         ps9Q==
X-Google-Smtp-Source: APXvYqxrr/uL0yeWv0l0AFEkJ0fiuFxZszwvIRMBTgsPNJXwasc7ZXW/q9+Il/kiADkCo486i0NA9w==
X-Received: by 2002:a17:902:f216:: with SMTP id gn22mr690564plb.118.1561495062448;
        Tue, 25 Jun 2019 13:37:42 -0700 (PDT)
Received: from cabot.adilger.ext (S0106a84e3fe4b223.cg.shawcable.net. [70.77.216.213])
        by smtp.gmail.com with ESMTPSA id m4sm4145961pff.108.2019.06.25.13.37.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 13:37:41 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <E84C8EBC-8341-49E5-8EED-0980D158CD50@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_D22B91A1-39DB-42F5-937D-A1034700DAE0";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v4 0/7] vfs: make immutable files actually immutable
Date: Tue, 25 Jun 2019 14:37:37 -0600
In-Reply-To: <20190625180326.GC2230847@magnolia>
Cc: Christoph Hellwig <hch@infradead.org>,
 matthew.garrett@nebula.com,
 yuchao0@huawei.com,
 Theodore Ts'o <tytso@mit.edu>,
 ard.biesheuvel@linaro.org,
 Josef Bacik <josef@toxicpanda.com>,
 Chris Mason <clm@fb.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.com>,
 dsterba@suse.com,
 Jaegeuk Kim <jaegeuk@kernel.org>,
 jk@ozlabs.org,
 reiserfs-devel@vger.kernel.org,
 linux-efi@vger.kernel.org,
 devel@lists.orangefs.org,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 linux-f2fs-devel@lists.sourceforge.net,
 linux-xfs <linux-xfs@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>,
 linux-nilfs@vger.kernel.org,
 linux-mtd@lists.infradead.org,
 ocfs2-devel@oss.oracle.com,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>,
 Ext4 Developers List <linux-ext4@vger.kernel.org>,
 linux-btrfs <linux-btrfs@vger.kernel.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
References: <156116141046.1664939.11424021489724835645.stgit@magnolia>
 <20190625103631.GB30156@infradead.org> <20190625180326.GC2230847@magnolia>
X-Mailer: Apple Mail (2.3273)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--Apple-Mail=_D22B91A1-39DB-42F5-937D-A1034700DAE0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 25, 2019, at 12:03 PM, Darrick J. Wong <darrick.wong@oracle.com> =
wrote:
>=20
> On Tue, Jun 25, 2019 at 03:36:31AM -0700, Christoph Hellwig wrote:
>> On Fri, Jun 21, 2019 at 04:56:50PM -0700, Darrick J. Wong wrote:
>>> Hi all,
>>>=20
>>> The chattr(1) manpage has this to say about the immutable bit that
>>> system administrators can set on files:
>>>=20
>>> "A file with the 'i' attribute cannot be modified: it cannot be =
deleted
>>> or renamed, no link can be created to this file, most of the file's
>>> metadata can not be modified, and the file can not be opened in =
write
>>> mode."
>>>=20
>>> Given the clause about how the file 'cannot be modified', it is
>>> surprising that programs holding writable file descriptors can =
continue
>>> to write to and truncate files after the immutable flag has been =
set,
>>> but they cannot call other things such as utimes, fallocate, unlink,
>>> link, setxattr, or reflink.
>>=20
>> I still think living code beats documentation.  And as far as I can
>> tell the immutable bit never behaved as documented or implemented
>> in this series on Linux, and it originated on Linux.
>=20
> The behavior has never been consistent -- since the beginning you can
> keep write()ing to a fd after the file becomes immutable, but you =
can't
> ftruncate() it.  I would really like to make the behavior consistent.
> Since the authors of nearly every new system call and ioctl since the
> late 1990s have interpreted S_IMMUTABLE to mean "immutable takes =
effect
> everywhere immediately" I resolved the inconsistency in favor of that
> interpretation.
>=20
> I asked Ted what he thought that that userspace having the ability to
> continue writing to an immutable file, and he thought it was an
> implementation bug that had been there for 25 years.  Even he thought
> that immutable should take effect immediately everywhere.
>=20
>> If you want  hard cut off style immutable flag it should really be a
>> new API, but I don't really see the point.  It isn't like the usual
>> workload is to set the flag on a file actively in use.
>=20
> FWIW Ted also thought that since it's rare for admins to set +i on a
> file actively in use we could just change it without forcing everyone
> onto a new api.

On the flip side, it is possible to continue to write to an open fd
after removing the write permission, and this is a problem we've hit
in the real world with NFS export, so real applications do this.

It may be the same case with immutable files, where an application sets
the immutable flag immediately after creation, but continues to write
until it closes the file, so that the file can't be modified by other
processes, and there isn't a risk that the file is missing the immutable
flag if the writing process dies before setting it at the end.

Cheers, Andreas






--Apple-Mail=_D22B91A1-39DB-42F5-937D-A1034700DAE0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl0ShhEACgkQcqXauRfM
H+CbrRAAps35LK3poNlahSXPmgZ5tD+3nAlaeG8JU1XTggnEeHdAHY7wdK713thT
OumdwU7nj1s+0ngxeUxPU/ZVWyuL2LjugpWEfw8lf0N/16hoTIUPBAe7kXce3jb+
eg72QT36y1srscGQ/95rv/DPfelxzC7WiVYV7ZHIIF2Cq31B34cZ7GF0zpi6oZSH
RKioHBOX1Qez1CksvAevhtSGf9e0dF1hNx7gyoVFnGb5V72P7WGGQqWSW4nSJvMe
xhzkT0wLU28MioHsIcnqwnZJdvCb66Z1FGvAwsNItELe2tch4JzZjVR5sbq/g0+Q
CpDZk350WiKaFzo9m1TO2Eiiog2vS1bqO+hZuwf7jPqcfIa6Tu9BdCx9U/bKp/rN
sEtDj+p4qnjTCX2ggozPxye92wzhbF2o25jjoofBh9x9ShQ3GAc/gaTxcR9fpuWJ
UmMwXwKMVXP/kvBaclrbz/zxaeo3ga7z3mFGgzxU6we9M5x1Lo+ppFxRpEPMIVkW
LUEIQ4emE6yqzOWLWH6iPnxly9Jtzye3jsiq6s7RPPUGHn1/SCdhVZG130vKEpkC
IcSmmJGlhPcI8wJ5/gwhAoxm9yLa+t0oH/Y6HUoNc722A3sCVRV5JWoHuK9MKBDK
IPKKud+iKoNON0zr28k4iNyK1XAO+7yAqjfBAmdm0grbW/nItxg=
=YBbV
-----END PGP SIGNATURE-----

--Apple-Mail=_D22B91A1-39DB-42F5-937D-A1034700DAE0--

