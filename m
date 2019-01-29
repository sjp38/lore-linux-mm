Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B98B5C3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:18:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF62217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:18:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF62217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA718E0002; Tue, 29 Jan 2019 02:18:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05A3E8E0001; Tue, 29 Jan 2019 02:18:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8BBF8E0002; Tue, 29 Jan 2019 02:18:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 909B58E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:18:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id l45so7554146edb.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 23:18:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5wwsCqGTmWd9crKYMjsuWcz4/qirMABgerjvP73ojXE=;
        b=ZHjqjw+WEqnIIr5XccNN/lnJzk5FXvsknwjevJWYwPxX1A0pxKxW3oHU1j3RTm/TVb
         sfg32dLut/mHTslyNy7+Yy03yXBQnW88R9/SPkGbxNd++szPtCdXgU3c6uYzzCYtGLZS
         YgeqkBh7qqqpr+E6cG27Oa8eedrxXbbXpoOB3Taui35Lj7bSXRNK9jLHkomEGSXrLEgA
         4cyTckIHl/VSwRmkXoy9LvitK0OX554fHGG2PnEgtIIzOqPy0Pl8L24f9/+dtE95Q7S2
         SZvExNUWTVgjP7vchnv0cUp/fxPRX0PvfR+/35QwmFzv/sxl6Q+rGEfUxzaixz7PSDND
         Zthg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuke2Kv4ieoUhvs/VzsvoWPS65g/VTW3iWxbeylT7Vg9K3v+CGd7a
	KLIb0rN6wkJXVFhr08osW8mLRTgvaX/V5ZBG2Bw0v3qdymrf2X6LDxH6YCo3dfvdKXVXrPmOTCr
	TuGNbJL7QAWzvzGbUHBcblG9wiceo11tG20isMLuccJiXUwEompzy4yEQt2f4b1M=
X-Received: by 2002:a50:8f04:: with SMTP id 4mr24502867edy.95.1548746322125;
        Mon, 28 Jan 2019 23:18:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6TGszADknS/rPmFMuXPeVKcIVZuuEyRQiKbmkWfEEHIEuJoz7ejrXcK82adJJNhhTLQJg7
X-Received: by 2002:a50:8f04:: with SMTP id 4mr24502827edy.95.1548746321277;
        Mon, 28 Jan 2019 23:18:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548746321; cv=none;
        d=google.com; s=arc-20160816;
        b=zTd8Gr4S6SJRFIB7bKfeQukwN57iOtTtBOjUP7hc4NJGTKK22oMDk2k4LhCsLdvrUn
         1M6chwdKeJGvfh4LSzHbLgp3Vy/Nwz2ij+GPHd3WmM8l5BRB6rXcYbw6vs2SyeiFTHcs
         qu2zx81wu76lFcKRyM02bLcsg7tHsyjH70D8K8n3j+QEXH4kVnQTek5vI+nBHsQJ1cds
         f6xSnBqWdPgu+AL+mDDMfOffA7Z5UhBb42YvzfZvACcLmttd15q08UUPgRKR3PolvPg/
         wHeCmEJRuacIXHWtMpbglffwsHT2QBbAav87/HCkE6iE1PL3XETTCflNDMFLA0Z1GyWZ
         MGig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5wwsCqGTmWd9crKYMjsuWcz4/qirMABgerjvP73ojXE=;
        b=YSh02ivYHaA4+NR5BuFqGKjP9gFrSUEj/5VTZcNDGqnaSBh8jqAdSWXZWMJGEW+aWC
         DJ06q4rE0MKYTOe9qLERajhPLos9/784xnCu6dXANUkJAAY7vnUXDCikeo1S5+5bwgeB
         AQOkvRQCXj1MT1btNMk03mlsZILp1nPLIE7B6QZGHIchLXIghkpDV60H8IryR7eF9dhE
         P3j+6vob8xZwrxNqDQscfBRZEqtVlROvCNOpQJfO+hV//iKxcXlo9txAFSJDH7G6omd8
         WRqXWEjf/7gdRh9hXAsmBKYOxv/En78py4454o4YWq2kkg2xwRcPL6gpW9QjISA4SBwE
         Mdhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si3037644edw.390.2019.01.28.23.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 23:18:41 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0B60AED7;
	Tue, 29 Jan 2019 07:18:39 +0000 (UTC)
Date: Tue, 29 Jan 2019 08:18:37 +0100
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vratislav Bendel <vbendel@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
	Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH v1] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
Message-ID: <20190129071837.GZ18811@dhcp22.suse.cz>
References: <20190128160403.16657-1-david@redhat.com>
 <e3247625-b25c-a18a-a494-f1e9a0148932@redhat.com>
 <20190128201902.GW18811@dhcp22.suse.cz>
 <725cd2b9-984f-d69b-1967-660d32858ce4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <725cd2b9-984f-d69b-1967-660d32858ce4@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 22:09:14, David Hildenbrand wrote:
> On 28.01.19 21:19, Michal Hocko wrote:
[...]
> > David, could you reformulate the changelog accordingly please? My ack
> > still holds.
> 
> You mean reformulating + resending for stable kernels only?

I would merge your patch even if it doesn't fix any real problem _now_.
If for not other reasons it makes the code less subtle because we no
longer depend on this crazy __PageMovable is special. If the movable
flag is supposed to be synchronized with the page lock then do not do
tricks and make code more robust because the next time somebody would
like to fix up the current semantic he might reintroduce the bug easily.
-- 
Michal Hocko
SUSE Labs

