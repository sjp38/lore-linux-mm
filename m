Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92A06C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 07:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 451AD21019
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 07:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 451AD21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7F326B0003; Tue, 21 May 2019 03:06:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2FB46B0005; Tue, 21 May 2019 03:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91FBC6B0006; Tue, 21 May 2019 03:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45B0E6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 03:06:42 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 9so425870wmi.7
        for <linux-mm@kvack.org>; Tue, 21 May 2019 00:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BCDVtsCA4fRRI80jdr090j+ebnC+z4xJdQUu/i1zpls=;
        b=ZJg/ImwKQ6+BBC5AAMsWjYW6ssMQesn9/HfNrxFWwvElgMs9hW/HY/++BwmBmoHlhX
         BEGpuYBoFndSm1qcs2bEqJmYhcQyJmPfiVEv+sQXkuPZUKKrOxTY+Z9gKR5+s1Q2GJEZ
         f1WoN7yvE4X30Q3JgVtz2WGNTcdrJp9iSY1wgcZB7o148zAjDd645axCyC6cUfW5CJGI
         QIE+ISnHzy3ggG8BHDXZYOv3sAdLhI5QZgZXzXOIvoCrT8MpIYWUg+buPb1/VXNRTtmc
         tU0fFIo7w44P7wfse+MkS3eohGyTKhixMJRfduebG0jQ0shBEJkXnISRpy2DgTZ4vWm1
         1Isw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTGbtKDLTZaQ2adWTp76qcD9tbXIzOLUT9WNj1+iZZbfHY17Mb
	HOkfxf1H0PE8dpmcsjP/4mvV5j3PY9X4lgswffHzjrxGh8ecOAAHwieSIcuC7J21DI6Kw/6OnHE
	r1drlJXWOIVcyCF1sEf/5+NI9rTM5p6zJWgXZvAndLTZPhlH2TY0tV20JN4vi0eWiNA==
X-Received: by 2002:a7b:c744:: with SMTP id w4mr2219415wmk.116.1558422401738;
        Tue, 21 May 2019 00:06:41 -0700 (PDT)
X-Received: by 2002:a7b:c744:: with SMTP id w4mr2219350wmk.116.1558422400827;
        Tue, 21 May 2019 00:06:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558422400; cv=none;
        d=google.com; s=arc-20160816;
        b=M8RszPAlkaXOjTr22BQLbiwJXYcvZx8L3PdVy6b2CpyxslU/Ogi7nUoPAvGdKT+3/j
         WNNJtv8/+CfyI8OBPtgyXCOam6/UuevGAfbjBTcLpMW7pSMz7iUpbOz7Fs/wqfHXPcK8
         OrTnukUoGQwlgR00NIGVAbOD7d1SXCZV8ZD9cUzjQf6Cq+fc+sQ8cocZBq9OVHpy4Yvg
         Hcc8tOOIFTBPCiZ76hDojCv1blS60xEF2i/m6ZBpK1xYZs3vA0cuhQKEXCgLPm0iMeLI
         NlSibDFOTAteX19XkLFT4WASXnKDiggPFBItuzeSkyDlIVUKuSakv4g48RiSVu8i0haD
         0U8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BCDVtsCA4fRRI80jdr090j+ebnC+z4xJdQUu/i1zpls=;
        b=CwNGQogYstZnukUVQp+B5t5Utu32FImJku9snE+hEYUbhaWp25sknK2We/Dym45fdf
         skWUS/yLFSqNZFYY+koNF3OmdjJQISfTRhnF8LPLs5EqnlvzHnomrC+9VNAttxEQ2oFI
         BXZZZvUjcx6LIETGrO8siEGsuAFzbeVSJCxKRBsxgXtJDBB8dAm1ggok8Zw+7SgwauNc
         gEcm5Aslp94/NkhHNjjYC3J8gLYlHA9yztJF7AnAeVghc0gv8KBBNzQxxXy4M+tWCYXi
         43/ZkgpeiauH/FJP0WLcNmJrRzJAqQvXGdVts1Fgfs4Ydj+TN9c18Vjk3tA75VHPoODv
         aAaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10sor1019683wmh.2.2019.05.21.00.06.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 00:06:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy+62EkTHounYwTTGspsUVLyMrAch/IR6B+AY9ezOb09mJ+jQU7lo14UYsu/j4pyAlmgZ1Q2g==
X-Received: by 2002:a05:600c:21c1:: with SMTP id x1mr2134691wmj.5.1558422400441;
        Tue, 21 May 2019 00:06:40 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id z74sm2922006wmc.2.2019.05.21.00.06.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 May 2019 00:06:39 -0700 (PDT)
Date: Tue, 21 May 2019 09:06:38 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521065000.GH32329@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521065000.GH32329@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, May 21, 2019 at 08:50:00AM +0200, Michal Hocko wrote:
> On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
> [...]
> > Regarding restricting the hints, I'm definitely interested in having
> > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > madvise() introduces another issue with traversing remote VMAs reliably.
> > IIUC, one can do this via userspace by parsing [s]maps file only, which
> > is not very consistent, and once some range is parsed, and then it is
> > immediately gone, a wrong hint will be sent.
> > 
> > Isn't this a problem we should worry about?
> 
> See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz

Oh, thanks for the pointer.

Indeed, for my specific task with remote KSM I'd go with map_files
instead. This doesn't solve the task completely in case of traversal
through all the VMAs in one pass, but makes it easier comparing to a
remote syscall.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

