Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9F8DC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 06:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EFBA20811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 06:16:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="G90htT7j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EFBA20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A60A48E0003; Fri,  8 Mar 2019 01:16:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E72F8E0002; Fri,  8 Mar 2019 01:16:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B09B8E0003; Fri,  8 Mar 2019 01:16:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58E178E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 01:16:30 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a1so8442385otl.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 22:16:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=HkJjVI6tIdHfZT2Gp2wLj/2Yp7f77KztMPdI+j+YZ6g=;
        b=ByRfJ1Bk+0gzSCEECIeVn7Q1ttDO+Zd8+Kh+ffZ4lsWKoRSz52TvAKjeJJqz/LKAKu
         7FeOGx82mmSCb6K5rrKpK782Vqaj0z5D5KWb31nMppxE54sYXHG9nuhMNzpZjArsrxur
         IRPWSxT51oaL+aoY0N8I85Ul7j5JXQ7N3jJkGOFgghuxHk4WDg+BrIxqYISGpnrp67H1
         PKm7wCtH9635mzB4P0rNBcdCyHtw+dF9A4ZtPIMEbwwhOsclTr6KOFusG3FCsfeqhiEp
         R8lB6RIlXrNQwMQDW22R/aN20zdNLVYcnmEtmSKCcrLEVpMZwS+jwNlpz4k+faQFqwK6
         PqNQ==
X-Gm-Message-State: APjAAAXpFrnZWeeKzhFYoAY+aAOw3OL8ZAvXsvMp3gAfFTxbAFjdZZB4
	beVN4eCEBn6w37Mgoha6rBkREsBkH3VdWwycZCiSpCd+xaswwyxGHHqzzwtC55ZqFmTMXp3ceir
	S4nn8ij3M1rRozfEajnh95HhSDrCRRO4VeBzBocbLuWrrEm75Eo3tkr+JJAQrayjR/WSxY3KfvH
	E1CSBbsJyT8/zIDfmZ6eywu92N97r4N8J6D8TDz7beGwbOZtreKO4FGxFpJiojYu3D6yo7BMK9I
	YbkdiSAlVgHndivNzpzWycfthjVXPsE6bcud664eZHuAnnUOtMMVBy+uqNiGUEZX5GQVJgQ5JXG
	yB2/mGCMgoOH9hNt3QmzAYd+UrQ+T1EH3lwhh1CfIDBaH0F9bMx0fhoJDXgRfjZvUQB8apjn0EG
	5
X-Received: by 2002:aca:5c88:: with SMTP id q130mr6991464oib.79.1552025789876;
        Thu, 07 Mar 2019 22:16:29 -0800 (PST)
X-Received: by 2002:aca:5c88:: with SMTP id q130mr6991448oib.79.1552025789197;
        Thu, 07 Mar 2019 22:16:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552025789; cv=none;
        d=google.com; s=arc-20160816;
        b=XfOVcojI6RALLMPmJ75G5SOwbicp/kdFLEmTtjall5lguHrobKmSnf5v6lvR0uLwNE
         Y7djjU49hgxvPMsfOvL0+06ZXVFHDg5Q6higqAGtEtUH+ygkPtqC/eqvRnEcrRoHheKv
         1jjSG5tdVoov6liM+5QztdBqEV0Y2pYABIH2T6MlfhldYeYy1BfpiS77lN74wkALDaMk
         kXcucTXMoXIKi0ncD1kNL9e6QiJCoVIdfdR50SCZeOjB8afOK+eFCxSEGDEQU6dnFW1N
         K8AFk8T7x/JaEC4jwmjybyETQj+Ib+Uurewxy3e7SGkrXP4spWIz49cITmwXiarfPL+i
         ouOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=HkJjVI6tIdHfZT2Gp2wLj/2Yp7f77KztMPdI+j+YZ6g=;
        b=BFuBiNTr11NwfmBm6UtGgn2k+t7mdZ1AGJo+YA5U4zgyhAAgDBGZjS5e4zS+cOV7Mf
         ZyNkwGvGnHR+HzHrq2ZbWRwGw+Ku4uE4U6q5Y7ywdvFMQczyj6HzDTh3amyxjO549NUu
         SM05g8xv9GqU+FT9657aZjXSXdnfdZ0U0Tx/oskHlj+OxXl4JDqLHY1Q2XxsEz5LHi3i
         O4DOVNBJcO3+8+ndwAX0BtCl3pA/sK21G30soLryuF7rUYY2pKag1a++PID+uzsTzprZ
         LL8Mr+J3VT4Uuwof2RWXTa+TQhHxvcOEirNHZTDHqebBIm+CIwln52ccuOTM0P7Sd7dF
         6voQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=G90htT7j;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i1sor3534538oib.156.2019.03.07.22.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 22:16:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=G90htT7j;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=HkJjVI6tIdHfZT2Gp2wLj/2Yp7f77KztMPdI+j+YZ6g=;
        b=G90htT7jURybdSoXMBltJSlWp4bqs4qDDNdMEVzS0yB9rEDYJMb9EZYPzWL0+aZsqq
         tYfMv3RLKpM4h3kZ4r0mGxdQ8GvTYdujS+2t1rFqXGhXgXgWzwWv82uD/dlyIl/Fag97
         m94BV+vyeMup1mx7be5Woj5MAb3TX+rT5Ldtrb2PEPswUEp6M2p3yoS4hc0QM0uK43v6
         Kz6n5eIxW7L4iA9Y+hEhuYWmjC9NSSAWgRNNV3Z6bmwYOMMGwxkjCkqA9+NqlE9nLPRA
         ITj4pm4O391cTLctYbAfdgFGs/0FG6s0lm0p5VzXULEnfcYtYs1axHOFBvThyFnjuYea
         Ksfg==
X-Google-Smtp-Source: APXvYqyg6kP94ErfGvju2F2CmJtzdYcpR4nmSHzVbmbmw9NSus2juATwoLdk28eKC1La9UVsMK0Nl6A6mEG1rRMyQfQ=
X-Received: by 2002:aca:cc0f:: with SMTP id c15mr7804163oig.105.1552025788429;
 Thu, 07 Mar 2019 22:16:28 -0800 (PST)
MIME-Version: 1.0
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 7 Mar 2019 22:16:17 -0800
Message-ID: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
Subject: Hang / zombie process from Xarray page-fault conversion (bisected)
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Barror, Robert" <robert.barror@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.010853, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Willy,

We're seeing a case where RocksDB hangs and becomes defunct when
trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
able to bisect this to commit b15cd800682f "dax: Convert page fault
handlers to XArray".

I see some direct usage of xa_index and wonder if there are some more
pmd fixups to do?

Other thoughts?

