Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCBCDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5B8F2070B
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5B8F2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A7286B000D; Fri, 29 Mar 2019 12:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3565C6B000E; Fri, 29 Mar 2019 12:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26B6F6B0010; Fri, 29 Mar 2019 12:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C55D6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 12:09:33 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 18so2663371qtw.20
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:09:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Am5kpFvsSPcpJZX1iSRCLucd0xEpSf0ByMp99+GyOZc=;
        b=dT8zFl+geXTklDxLlAEShTWVOZX5bNrnFbHugkKbYmdGU/EYnx8f0xkr9pWMTuLdqG
         Wj/UnjCisQUrVPFXDwBwJNJ0W+NohvAasO3rDEaozi5vLL6JaD6j55gwPCD2tGY7dbpa
         Vs3ReD2ly+hPIsILPyu5RE8oldTD3GhLSlqtvQ1jakgiJNuKnL1S1rxXtjRIuovR63G9
         duVIZzxi8x7e5lTafUjqW0vIVPiEC8O/b1duzGzbBsbNvbHENABCkBq/Q/U2HlVLsimA
         bfYfiCWX9brDjT3P51klQOBi/DYgbIawb5axpje9cmrOdGEtjULcDRVafvq4RdQ/kdgj
         7+Fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4m36EBkewex9LYnirlTi6dFGPTtT/rLBA3L9j7rsYoPuyleiD
	SvQEjuidLu8r/QERvIaLD3R+gSVeBu+bMogBHn0PnP8uVKuZsMIL8tSXGFT6ms85YycFJvF4LXN
	YrOuGzGoP/2tTD/dmic9Qfpksxe/04pS6Dm5cMLEZdoqpLuKOB+whfEFW5obCaGNMJA==
X-Received: by 2002:ac8:1497:: with SMTP id l23mr3807983qtj.296.1553875772740;
        Fri, 29 Mar 2019 09:09:32 -0700 (PDT)
X-Received: by 2002:ac8:1497:: with SMTP id l23mr3807925qtj.296.1553875772129;
        Fri, 29 Mar 2019 09:09:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553875772; cv=none;
        d=google.com; s=arc-20160816;
        b=oUIk8/Uz0YVtAUniNOnNX2RUWC0tm8MNYIu0Ys7XkHKlTsSYd+X8nXoOV22o1A5277
         nfjtATDO4WM8oTK7QPKPJsYDuBfqs2y5cHioqGST4u+v+YvbwtfUv6jbbOE+b0jGDX56
         a5FFs30ZI4yPi75+rehK8UaNqCGimOi1NAzG2Pblydj347XPVJMXR09TNSeZlahje2HJ
         x+QlaQg5gVC2oGDNciDUSeIkJAq8GFBylJAhde+hn9RUUSpoREeG+6QT9tzkI9Lq2WDV
         tpuyFsT4s7xfuVqnpKNIc0K3CtKlEPK2RZbprlnlBIFCuxtBgiV5y4ZFJWHnwsxceeOJ
         NSUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Am5kpFvsSPcpJZX1iSRCLucd0xEpSf0ByMp99+GyOZc=;
        b=Ryoklq4RQVcqtR3B4r5zLy0L5N1y2P8G7v0tIwwrN489MnJ5Ckc91/SNe5hQgXhVbe
         6Gy2dCksvQlXx11DxVVkDq/CNo4zpPdOz6VhyJisY/aXbCdADIdIK7965M4X+JHX2VKT
         h/VyoWgKp1CcVoCNSzr75ZRtpPSK44HvRKukzWIpglnqBFcmi+ZLq/tNKsJIuSA1iOGF
         Ez3fld0tGW8Rxa4iJzpWlb1VKnh78Mr9X7pJRJwedYY9cxvgIasqXrTs28usN1Y9jMzK
         i6nHZaLwhQw0gNH9+vCU+gEjmwRR9dFCz3N7DapT9XfeR907LoKWNA6tVPPfAnJGegav
         tr4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d5sor2615132qvd.40.2019.03.29.09.09.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 09:09:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwPvWlggOCOCZOE++FMeDaYp8mT2DXFtIePYnvadkTVpeTZEstVj+Ou8oCcjYWRclAjhRMeGw==
X-Received: by 2002:a0c:b095:: with SMTP id o21mr8324819qvc.162.1553875771921;
        Fri, 29 Mar 2019 09:09:31 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id r15sm1562334qtb.22.2019.03.29.09.09.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 09:09:30 -0700 (PDT)
Date: Fri, 29 Mar 2019 12:09:28 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190329120907-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 04:37:46PM +0100, David Hildenbrand wrote:
> Just so we understand each other. What you mean with "appended to guest
> memory" is "append to the guest memory size", not actually "append
> memory via virtio-balloon", like adding memory regions and stuff.
> 
> Instead of "-m 4G" you would do "-m 5G -device virtio-balloon,hint_size=1G".

Right.

