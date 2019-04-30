Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E00D8C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A34D221734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A34D221734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D39F6B026D; Tue, 30 Apr 2019 06:11:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E156B026E; Tue, 30 Apr 2019 06:11:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04CE36B026F; Tue, 30 Apr 2019 06:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A95FA6B026D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:11:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f7so6154420edi.20
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 03:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=driYKFSdNgFj8zC23gEIjPPdUP+1LLbPrpIzN5AENkU=;
        b=dTQWdvrEqLHCpMDCdPUfTYp2nV55ZsBcl94QXy01o7fvfrI1mOOlJmebqpznJsQBOA
         SnGy61yQYqiTZcCbraKQXUHCVqDbn2j8FsBvL1/paQEHdGsTul/jBybl8JFgWlAzkeI7
         h2kRUuNZDUnvbkKdm6J2JZT49aDzJOnFhuy/Z9d6Mt+dNzZWqHXo5mvZLjOirqTqcbCr
         vRR+nS43NQEJ2gSPIph4u6SGkcf8VUAQOapVWhhA3Ww845QojzNyb3RLntfDqy5uLO62
         IGyckyL8hkyW9g6XtKOUX/SQASGa9LOsYiEswnum0VeXkIbLcmPqg9dibE+vYQ7f7e6J
         H/0g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWEx2ue5YSzz5SYXrmy2cDYO82ZwEBjOVYPb2n2i77P14FURBiP
	iFTB6QJx0bfW1Ox98I17gsCrJ0R4nZLBdX8wD6NclgW/9bMDKWhvTnTthSBQCshVKnRuHus8Ubv
	2cntmzSSxrZ5QI+Xv0ej5YSKCSTTUDlnoCiMOgljIAVxb2wMM/NgT6WvDHLwFnWA=
X-Received: by 2002:a50:a55c:: with SMTP id z28mr4458671edb.71.1556619086264;
        Tue, 30 Apr 2019 03:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9L0GMYc9z/IhvlU9mtDOAtnDTAR1aVejmlD3mwNeqKuBgtr/NMdaiH7jnem0FT7F82Q9j
X-Received: by 2002:a50:a55c:: with SMTP id z28mr4458584edb.71.1556619084773;
        Tue, 30 Apr 2019 03:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556619084; cv=none;
        d=google.com; s=arc-20160816;
        b=P1Xh9vezbfzddUUPAcmNyLLSmqGTBNh+OZlPL0olKRQ9wbukJiwGfIu1VN644+GNrj
         HajKRJcPAoapjjEIY2uFDQ2F7aOpUTQf/q7JtIUCzHDkUVSZ2tLw2lDvu2QAWg31rbMF
         xGjwWVJqnum1ozNMQq7dR5N/ze9H1vqz2b2xfRYTPYGqKlXFuMUWNVzI7UHOyfhsvCg3
         8OekHcbRUw6YOahI44fzy5opAAHTGGXxl0Jz7tF6Za1dlHJST7IjwfyJGgmUZ5xPfrog
         Si8Jhc6Fg4bmIeE7VCcJ7cvVihILryDdPc3s4KfZVwU0G/oow7ks6TXi19xWwxEUWWNd
         Wgfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=driYKFSdNgFj8zC23gEIjPPdUP+1LLbPrpIzN5AENkU=;
        b=kABpOVZ9KIIszVHOF11kwMCEzyNkiRpGXx33DqDTfYKS560Od9sig7k9bhzDu2nIr5
         fZpjqbsSyNLnn1VUtusrHsicof/ci2i9DrEVa8SZv67RSVhVO3dpIQDj7Mg4+QiuFkiB
         cZnOEz0bNv6reYEVgF3ddUCeZTC2mLTekTVxV/gOkqYEU9SqCtGmuUeuL3kkhDlTRSQK
         Y+PvoDsj0N9b3VLgRxPXYaIsgTA7EyrmbVIT1WOXpyBUShQJf5IbWS6AeD8prE9nXqNP
         yLq1VGh41IM7lSJh8KuE1U+Fcy94RLy3NHW8pVCw9I2DLu4XiZcL9o8RrgeBYoCuET8m
         cOeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a2si16883694edf.93.2019.04.30.03.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 03:11:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4ED0AF56;
	Tue, 30 Apr 2019 10:11:23 +0000 (UTC)
Date: Tue, 30 Apr 2019 06:11:20 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jens Axboe <axboe@kernel.dk>, Jerome Glisse <jglisse@redhat.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Scheduling conflicts
Message-ID: <20190430101120.GD3715@dhcp22.suse.cz>
References: <20190425200012.GA6391@redhat.com>
 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
 <20190429235440.GA13796@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429235440.GA13796@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 16:54:41, Matthew Wilcox wrote:
> On Thu, Apr 25, 2019 at 02:03:34PM -0600, Jens Axboe wrote:
> > On 4/25/19 2:00 PM, Jerome Glisse wrote:
> > > Did i miss preliminary agenda somewhere ? In previous year i think
> > > there use to be one by now :)
> > 
> > You should have received an email from LF this morning with a subject
> > of:
> > 
> > LSFMM 2019: 8 Things to Know Before You Arrive!
> > 
> > which also includes a link to the schedule. Here it is:
> > 
> > https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk
> 
> The schedule continues to evolve ... I would very much like to have
> Christoph Hellwig in the room for the Eliminating Tail Pages discussion,
> but he's now scheduled to speak in a session at the same time (16:00
> Tuesday).  I assume there'll be time for agenda-bashing at 9am tomorrow?

I have swapped slots at 16:00 and 16:30 so there shouldn't be any
conflict now. Let me know if that doesn't fit.

-- 
Michal Hocko
SUSE Labs

