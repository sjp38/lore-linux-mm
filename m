Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93FB5C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 616A720684
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 616A720684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47CF8E0004; Fri,  8 Mar 2019 14:13:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCF3D8E0002; Fri,  8 Mar 2019 14:13:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B70708E0004; Fri,  8 Mar 2019 14:13:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 861B78E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:13:52 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d49so19626551qtd.15
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:13:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rJWrJV5ChdUEPSniGiJcJC+tB7j6ePMLkPB91BYXrNU=;
        b=lFit6m2oC76e0+6nbqWkw5k6+xLj4GPkpuDIiEy1CMbiS4fdYIdYJ8EtdQRCY9aQPv
         Hwii3zBGX1AG9DxoplerNHr9xdzYO9cU9rBMBNowSOJNWgrNNNsA+AO2NdH8OFIn7cA6
         +4LT7B38qmGrvUG6zkv72nm42Pub1k8he7gzCdTkmGvzVulYKJguSuBguRI9JMLBP9oh
         R7AWz2+cwp+7vsSDi+XrJ47MWHQOUN+UH+JMYWUh2gOkaxpD1/ZLB74HVQ7Tjn2QOQ2S
         kfRQom1sGlHHAdwcvUUhyNpNBMDlgPrLw4dM3quM5MJQv4YhtKxak8dtMIu6/cYiF8T9
         WCag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXlBBrZHyv3ls+cC+J1g52E9q1037UvuVUOBT9PdNwwkhz0L2Dz
	V8zD/5qmSaYB+4YFOVIxEdLWz6Q41keiVQOLrw0+CpcnSdVlmur8ylq+g00Vw00MiZ07bEutysA
	99rSlndjQXC2l7D1dJsZnUhSCVlatc9fZOJfASp+gqB+TcLN3npQTIL9SDOzpiFDlrQ==
X-Received: by 2002:a0c:ba9d:: with SMTP id x29mr16347781qvf.112.1552072432343;
        Fri, 08 Mar 2019 11:13:52 -0800 (PST)
X-Google-Smtp-Source: APXvYqwOykNjoU0OwWBcEMijPbaooeHHicz7QtaaigUxlpwyJ3+tlJTjE1fdIqfw5xyTIyL049wf
X-Received: by 2002:a0c:ba9d:: with SMTP id x29mr16347748qvf.112.1552072431717;
        Fri, 08 Mar 2019 11:13:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552072431; cv=none;
        d=google.com; s=arc-20160816;
        b=qbeI2iTL+6QV97VlBHRAoG+QzVnlN/uGDzRIfSF4dKRIdFOdCf7HXPvcKcs53DPKmK
         D7fJuhb+rKr9eVttqcVw+7g7Z4Wl21VcVvKTcvKy19jvzcOqFhUSpdlSxDmq4IdzInpH
         0a+KqEnIywRJWzdLFJVEtpAOLknNqSZmg6Z2BaU9s9dZM+KKNr7trerPQb994SyhKvt3
         VDxcP/L3eyH2fEVov3qbltC+aoiR6G4fiUDk0YU1f9PkgduVA2WTpjFrUxqeG1XJWTQo
         8wrtew5v4l8Xs5R0kzups09NcBLTql+QgZvcQY86jkb2IwnWtWiim/83SDDXtlFwvtQg
         J79A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rJWrJV5ChdUEPSniGiJcJC+tB7j6ePMLkPB91BYXrNU=;
        b=D7TOYWBtqWrjEnHfJ0LJTg6dZ1P/4tqTSQrOvWot/O8Ylc98+bZxqQKptLvkNB+PnM
         XR5y3dT7FGSpDtF8qgshgc6kS1doLgoObiufrYZV7JbqwKCSIltpJukcW4nlfgTSgS+Q
         yTPyGwv0Z0hEVegxA/CxSbxE9891nU7VHZaOwC963OLUhiVYckMVy3wmuDdfNqubQRLL
         D2P31HIDo8LsOqe1gCNFP+crfyuuJWlRJHEtSjw3dLYljoQk0kIqOvaILG/E1cXJkqa0
         FVGVTy/SsKLHBUHc4Lv7yGaYR0DvgmZS+u7SHbbU5fCnXOTFGXBkiI4eDkqmdY8LbLmb
         VtLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t80si867278qka.200.2019.03.08.11.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:13:51 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E189D318A5EA;
	Fri,  8 Mar 2019 19:13:50 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9EA091001DD4;
	Fri,  8 Mar 2019 19:13:46 +0000 (UTC)
Date: Fri, 8 Mar 2019 14:13:45 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308191345.GB26923@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <43408100-84d9-a359-3e78-dc65fb7b0ad1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43408100-84d9-a359-3e78-dc65fb7b0ad1@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 08 Mar 2019 19:13:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 04:58:44PM +0800, Jason Wang wrote:
> Can I simply can set_page_dirty() before vunmap() in the mmu notifier 
> callback, or is there any reason that it must be called within vumap()?

I also don't see any problem in doing it before vunmap. As far as the
mmu notifier and set_page_dirty is concerned vunmap is just
put_page. It's just slower and potentially unnecessary.

