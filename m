Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71627C282DB
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:11:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E17A20869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E17A20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F7F58E0002; Fri,  1 Feb 2019 04:11:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A8B68E0001; Fri,  1 Feb 2019 04:11:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 672058E0002; Fri,  1 Feb 2019 04:11:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 071AB8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 04:11:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so2503550edb.8
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 01:11:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+FAcYsuEaZcyqmBNTLPZO8QNr4gjsGW0dSoOPRfKHlA=;
        b=avmGHuOrwsbo4HMkZzq6gzmNcU3MSXDxZSiTFQCKAqMdL7C2L8/7hDVujuZ4Xa7zcX
         FE+DBfmLqQKTGxjxHZj0RgMsYLUuoRKM0VIkM1TLHFi10INJT8CnPSBT9luhQ9mNs4hk
         JeE2c3ZVS505TPRAgcEhapJ+h351F34ZeIX45W51AY3H7+5aZ+6rU86dLsj1rxF9sJnm
         CbZlcc3PZeMxs81nOO2i9U1INnGYtek390/30DL2W6LIztG50wlbS4ZDtWngdPkbn/YW
         4L6KLqGk13XT90WQ6zBvP18HMNEc0KbYl1WpQYFEpwKA4Z/eIOu+FFlUjQjqB6SgnYtw
         5QoA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuke1fRE5pYZCEnrkeZQoWEyQamMFjKJW9YvD/irOBeICgHZVg8MH
	I0arOe4nQfcry+5ho6KxKQJomVJXCUPoqDvv+ZdVbfBtRfAjS1RSpwuSow4FQy0NsIHQuB5NKKJ
	/v+xAJnXCwDtHsOHC62bQAb7NEbs9kPSC8Tzh10Te/ZG9MpHyAYgaYoGbSClVKwA=
X-Received: by 2002:a50:da43:: with SMTP id a3mr38859916edk.62.1549012315556;
        Fri, 01 Feb 2019 01:11:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5T+9J6nvXEmFu15eg3f6pKqIlvBwERxZqdBX6QvSdxb4uVi2NDGWdgeO4XfBDiALNLxQwO
X-Received: by 2002:a50:da43:: with SMTP id a3mr38859869edk.62.1549012314733;
        Fri, 01 Feb 2019 01:11:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549012314; cv=none;
        d=google.com; s=arc-20160816;
        b=q8dLAwblxXSso6d0pPCctp0WwvhOHe0BtOGTh3tE3O0zgBm7QGHuC89ZlXW8rrGGzG
         QxOuaQNvomd2hv9X9XcXqV+wAEyCytAML00f+jctbSKTHmPhlrwuyOrEbW3E32V9ysLw
         PHgeZH3hPVEOzlwjrCw84DTbtv/mgIClyxoV7/zykVfBtl5NcjWSN6SEcj+YyIrR/LQd
         xqYuiJo7Sw23YJdcN0V0p98FnV2X0+pyC5Ws0zpIYOs02re4YowRmP+76pguxf5qB9Z4
         j5pPTu6y9KfY/+lNCl1Da4567ZKuQ/iFkBuOk7cMrwxWhRIwPTY5G7/aAy0V4DdMqG/G
         FZDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+FAcYsuEaZcyqmBNTLPZO8QNr4gjsGW0dSoOPRfKHlA=;
        b=GFDJl0JNBa50gIUVQeabVbUwn3j4U2+aOmRw5sBx7etRhT0GFAuvQNk0mG7uW0MI+a
         CgHy5zfsa1QyB2O8gfrVgs2TW3lfo1a/JDTc1Dps5MrgDqjaM1hedVHoS9rmri2QsyVL
         cacoGZrr3kw3bafdNohitTuf8zIGBkIBEBvopGTXpUVcog1rz3KbWoJXT4Cqrzt6Eq8E
         tmqmjx5xqBhSv5CtH8vXtpqoDtY+CoqfBmEe4Zf7rD7RiXDUr87Cd37rOWzJlcBj+1mc
         FFM0U3XkUQW5u933gHwCqkndoV7U+Qc3GoYso0xC5ijdZHMo4XlNl83pEypQ0c6y19IO
         Wvdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v27si3019564edb.444.2019.02.01.01.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 01:11:54 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 09D1EB047;
	Fri,  1 Feb 2019 09:11:54 +0000 (UTC)
Date: Fri, 1 Feb 2019 10:11:52 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jikos@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jkosina@suse.cz>,
	Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
Message-ID: <20190201091152.GG11599@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-4-vbabka@suse.cz>
 <20190131100907.GS18811@dhcp22.suse.cz>
 <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-02-19 10:04:23, Vlastimil Babka wrote:
> The side channel exists anyway as long as process can e.g. check if
> its rss shrinked, and I doubt we are going to remove that possibility.

Well, but rss update will not tell you that the page has been faulted in
which is the most interesting part. You shouldn't be able to sniff on
/proc/$vicimt/smaps as an attacker.
-- 
Michal Hocko
SUSE Labs

