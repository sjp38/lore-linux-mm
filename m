Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E00AAC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 07:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FD922073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 07:41:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fMgW8PzH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FD922073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C9A86B0003; Wed, 17 Apr 2019 03:41:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278856B0006; Wed, 17 Apr 2019 03:41:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1902D6B0007; Wed, 17 Apr 2019 03:41:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB7306B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 03:41:45 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id g26so4725685ljd.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 00:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TsZQ54Mb58ojmhd4luSv5Cy/zFTCqmtd7c8rf02fwtI=;
        b=HIeJTtqXlIKFGIHz+AEyo1DnM+Gb2okziSOMe2tNNsqNgo+LPIoJWq/od5B9M9sWWg
         zQqC05WN3zVDdcsTQnxNUTqm4x8Z2VqepKrPywjO6sZ1eQ5eWhlY3LOQLrgebDwLJzsE
         Mk/JaJ074M08xHGNXrWpJvfTa7CdWQJGM5IBCSNUsvWx1jwoPOI/SVNwxugAhxHHhfsf
         MZFxTB4U2+9q87ZDIbzP/XQQcYBawh/30i2u60bS93czUhewfIhD5KsB1pzWLvGJzjvE
         dAPcU+Oc8tVBmj456Xv3p+evwilIvVccPbBdxGwoYhMWf5nEVYjap+hwmmFVmPD1IvkP
         b9Iw==
X-Gm-Message-State: APjAAAXOe/3oh4DCrDkPJSt53BBD8YH2LzHyA24qc43zzFZm9XZs3pN/
	empqiqc+ABFkUd95HQom1Sa1bWs+NfSfkH8fLHfrbiKG9c6dx7ZDIjjL0dXi5AOD5/+xptHVnZF
	LAxJDeOA7FvZVfcaEPfQhajTw4m54Exp/RLkKoIEp96vwN3b+WNz7N0PUPQsPckWjpA==
X-Received: by 2002:ac2:51d9:: with SMTP id u25mr18902007lfm.91.1555486904728;
        Wed, 17 Apr 2019 00:41:44 -0700 (PDT)
X-Received: by 2002:ac2:51d9:: with SMTP id u25mr18901933lfm.91.1555486903313;
        Wed, 17 Apr 2019 00:41:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555486903; cv=none;
        d=google.com; s=arc-20160816;
        b=tJDffdVyLsAb1+gUVEoPno0DyOD36bbRM+N/nrvhVJ03HO1Z4T0qlCV02EBpfejiFU
         5E614JgAoBYjeeHhzr/B/iXcZcM0nboNXpM92+pukwLT7MtOvEduDJ3V4GPGPBPJNdw4
         VUSg6TMjUoa4KTWQ+wnGQ5svKkYEkLY31TRWxsBioOomNBOB11uMKkPmcJrxyrIk6S5l
         b33mxqZKnzoDPPkn5zeAKL8yaQcsztQaGCRBjKf2cffk1iYkSg6/3Qnf8mA9CtdjZY1Y
         WQFLuZCxVbtxJ1F/l2q1wXmEZ4mgmlLSVh681RdBQB4w8W+Q0FrwND3DenRTQ8TjA0tG
         7Arw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TsZQ54Mb58ojmhd4luSv5Cy/zFTCqmtd7c8rf02fwtI=;
        b=gomdGwrTSm2zaruczDRLitTAvF/NuxVodV7stGhAuTLFeX1wsk5wju2PCWmoRsosrS
         hj5f6ozyFbJHzUDJ6Sx5UoPFz2FRFP8wroYZcIsR2wcqhIeKyA9Xk9wbF8oN/EhjqMmf
         1rx+dAQZ5jT1cnF75Qean4TRWMq0YJTNLxF5EQ2iIlTpOiAyH3YHtGeJnja4nsMnFV4a
         wKTaHS8mmdK4leiP3VpDBSFs8aTDHdIDmvS7fsSoTwilZvnhoZBF3jlkW3iqk7dEWKEh
         1AxOW3NCHus9wXdQCbKYXla/lysJK+0ykP33zSvDuomRl3/qqGBr39hJE0KIbJhuDUs2
         mZ1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fMgW8PzH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor1896057lfc.12.2019.04.17.00.41.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 00:41:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fMgW8PzH;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TsZQ54Mb58ojmhd4luSv5Cy/zFTCqmtd7c8rf02fwtI=;
        b=fMgW8PzH9WCt/OmE/UBhZ+VVupVzHD99xmsYUq73sxK68TNLBa7xsVQrDq6jqVUl+W
         pGyZy0cP7/bqLnGOqXvipQ0gK5MzD6wC2btKnabHBTaAibd6fO5C/HLvxpMDkeNWBO4/
         6vnbloCy/Fbm4TNmYVDmWPcXd2FuVSJ87ztWqJen1j01Bl1j+WJ9CnfIkNU+Wt5c+LWu
         BzDEREygS9BrT0UDbL2zzlpu2BLrS0VCpyozocAHVR7uv0vqt37rw0sDA5cunIvWvvn4
         OJM0mtQIeLEJSBQrHuuklBa1mvB6RreAGA+qRH5AeYpdDUI8dpJx/K1uQZsK6QBaVRmo
         KGZg==
X-Google-Smtp-Source: APXvYqw5ECPwxD37+hTt5ipw7RkA1Q3i7SdFpRyl3rgucmQGPVxJgB4cvMcM9QT7bHIs0228e2yjmAmb0L5MHMZt5pg=
X-Received: by 2002:a19:f001:: with SMTP id p1mr4731539lfc.27.1555486902459;
 Wed, 17 Apr 2019 00:41:42 -0700 (PDT)
MIME-Version: 1.0
References: <b86e6a5e-44d6-2c1b-879e-54a1bc671ad3@gmail.com> <20190416161840.c54f8fce7557e24fe0922338@linux-foundation.org>
In-Reply-To: <20190416161840.c54f8fce7557e24fe0922338@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Wed, 17 Apr 2019 09:41:31 +0200
Message-ID: <CAMJBoFOz41qyxwnQaJbDuv3n0Nzbzmwdx=Kyv=1wV51jr0ivKg@mail.gmail.com>
Subject: Re: [PATCH 0/4] z3fold: support page migration
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Oleksiy.Avramchenko@sony.com, Dan Streetman <ddstreet@ieee.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Den ons 17 apr. 2019 kl 01:18 skrev Andrew Morton <akpm@linux-foundation.org>:
>
> On Thu, 11 Apr 2019 17:32:12 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:
>
> > This patchset implements page migration support and slightly better
> > buddy search. To implement page migration support, z3fold has to move
> > away from the current scheme of handle encoding. i. e. stop encoding
> > page address in handles. Instead, a small per-page structure is created
> > which will contain actual addresses for z3fold objects, while pointers
> > to fields of that structure will be used as handles.
>
> Can you please help find a reviewer for this work?
>
> For some reason I'm seeing a massive number of rejects when trying to
> apply these.  It looks like your mail client performed some sort of
> selective space-stuffing.  I suggest you email a patch to yourself,
> check that the result applies properly.


Sorry about that. You can never be sure when you work with
Thunderbird. I checked the tabs were not converted to spaces but
Thunderbird managed to add extra space in the beginning of each
unchanged line of the patch.

I'll just to a v2 patchset today.

