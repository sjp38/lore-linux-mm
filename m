Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E87BC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 16:43:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C50B62080F
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 16:43:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="eWcKjS6Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C50B62080F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CC9C8E0090; Tue,  5 Feb 2019 11:43:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57B608E001C; Tue,  5 Feb 2019 11:43:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41E798E0090; Tue,  5 Feb 2019 11:43:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 162438E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 11:43:25 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so3677854qka.10
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 08:43:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lzbublII2+hYOIz0r1P39cJtjHHFawWf7/THbJtZSpE=;
        b=Udd1zk7Atty0tsJPnbf6+DjysBOnneH0/fCh/VSQvOt5G6ekbn5syKqlU5rYf/aZ5o
         kKvYBz73RoXMXcYJCtTbXQ/6IIFeFmSxyC1POR7K3ePL5EkYR70t8eN+zFXlkc+eYk9h
         1YGyK8P1HHBxgHJpzitiR3vy/gc9TRm+MmJxaZMdGSTohIUqh/7kKQ6x8IzAdLs6/9l6
         jEoszBclxtejRsgeCbrdguZoJzCkoxUQX4N6NiculDLTS2LwnMx6Uakag3zVH3b/rd+e
         sI7lMHaHpaKI0r5XKnbhbBPtuappHSOfIZvcVM3nW29nIJNiDx5FHS8gvfnOdT7uFWZu
         YKVg==
X-Gm-Message-State: AHQUAuZs17qXD+tIPTp5vjJ93dxp9h5dQhBzXhfyLCUiTTwLdzgSBOij
	I+5YTNbc0bjZVrlIf+RrMUW+uGX4WOy5ELnkz+wM4zc+F6jYmWLGuVj2QK6IAs/CTToIJbQtqDh
	9WmJ4X1pDpkGl3aJa60voijMeYsqYs49zKyzSj4bx1Ny1JABvYsegIeKrSALDxl+yKR9P/NVK39
	+up3kVL1jNbCalpF6tohxkRjug0MD7bVKC/IAWlDsKIlguudrhRUBiXcDD5W28LIoluy4tSTRcX
	Ok3laqwEP4pU1nM+UeDHSonwr3MGphE5dXEA1YLEdLk0Mw6e9yfemdhsUoD87yGj41q2SE271b9
	HYrtOJyytO2/7e7OSKwN6NijKqwiqZKduI+qL0rkyFcrRkHo5UgTElPvZ5KWxEHL/4du7lfO9/f
	l
X-Received: by 2002:aed:2185:: with SMTP id l5mr4408781qtc.276.1549385004855;
        Tue, 05 Feb 2019 08:43:24 -0800 (PST)
X-Received: by 2002:aed:2185:: with SMTP id l5mr4408754qtc.276.1549385004365;
        Tue, 05 Feb 2019 08:43:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549385004; cv=none;
        d=google.com; s=arc-20160816;
        b=jFQkU+vT+L7psYfXSUsuOXeCdJ71USiPNwo0Yuo+C08vwM1/Y1NZ4XYd61Mjsi+RvG
         wAewFlpM4+RiZyRvapwO/D4MeO+0zdA8RKZhv5xxBm6hecbEVMwL2FlMyzOjeSUPQUsr
         RakzYJN9QJCNKXCkxfqw5reOoyI44q1YC7mRe1wmIYzc17V0kYmRWnXk3sPfKXXmq0sU
         iA47fZGQwC015jllBImwl0A1IpWBIqtqRNfM4leOzsUQOSLG7JMr3gF+wncroA68rv+N
         rkvBVrFK6DIKlS5zz6lZNzqBSxI92Ui15CvZKfPbEMGHoMlRKKORB4CLeRNZFJP5AbKz
         rP7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lzbublII2+hYOIz0r1P39cJtjHHFawWf7/THbJtZSpE=;
        b=q027ZdD3WHiMJEGMtrfFMCAtrh3BDZemP5cZvjasZp4qsmyA2hyeE6hXpZlDKmzOn3
         HDThqAg8mOVW+9gqP88jJ3KrO0C51sXg6jHLtMgYKzo0eEdnTQLX+gqKPeOoUmalHcZI
         8gLBkcF3yWk2tlRzc3jf1oB4GupQDoINODuXAKpgabxcnm4Sv8RMJGm+o5b3IFtc0ZLN
         xzBM725ZH0hY/s8SwuAjQLd7CobE6f/G3iR+1fcr12mkOWzJRTV6OLhmyDOZGnPQ33Xf
         M3p6XKrHj4yD+FtVdc/GXsXzgdC6OQ5AatsnhNUZchh7JQAZ4A8wfqYPakxUkcRRrS0r
         g1dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eWcKjS6Q;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t17sor28333618qtn.22.2019.02.05.08.43.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 08:43:24 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=eWcKjS6Q;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=lzbublII2+hYOIz0r1P39cJtjHHFawWf7/THbJtZSpE=;
        b=eWcKjS6QnJ5D0Wj988XJQCMPCXakqUMrBJrAJxf5k0InjeCnj4eOZTW9iqGlF6IXuY
         3cgBpxD5usETAY0pt4VTahVm+vCCkkNPYuecA5XWXEs8eN49PPbmtobp138/CdJoQotg
         BAHQmhRzbg+aQ1ysYxPavuTuPTaRJO5/5GbqsHrak2fz6Xi4MOQNh/a/2Xpyg66URC84
         X1iFPal6VlF0QBixZV4EqAVjTQmVwoJQov8Jl1viWWGI2ZdffZI5oc3Lo/2WoHeo2TqQ
         ixekM1RQGVMF53fS057D2gdW250TrPSTcqLE1ER6h7uaPGWParV0LAzBY6amsINznc0g
         AWyQ==
X-Google-Smtp-Source: AHgI3IbV1MHc5Bckq09k1prt5wO82s0UfjkRwuBEy+uK/Vd6iGHeGL4w2JbCHRXk1DS65gT54Lr7Rw==
X-Received: by 2002:ac8:7416:: with SMTP id p22mr4294541qtq.318.1549385003864;
        Tue, 05 Feb 2019 08:43:23 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d78sm16138603qke.94.2019.02.05.08.43.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 08:43:23 -0800 (PST)
Subject: Re: mm: race in put_and_wait_on_page_locked()
To: Hugh Dickins <hughd@google.com>, Artem Savkov <asavkov@redhat.com>
Cc: Baoquan He <bhe@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>,
 Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190204091300.GB13536@shodan.usersys.redhat.com>
 <alpine.LSU.2.11.1902041201280.4441@eggly.anvils>
 <20190205121002.GA32424@shodan.usersys.redhat.com>
 <alpine.LSU.2.11.1902050725010.8467@eggly.anvils>
From: Qian Cai <cai@lca.pw>
Message-ID: <1ce33d5f-1f0f-7144-2455-fbae7f5f82c8@lca.pw>
Date: Tue, 5 Feb 2019 11:43:20 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1902050725010.8467@eggly.anvils>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.079042, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>> Cai, can you please check if you can reproduce this issue in your
>> environment with 5.0-rc5?
> 
> Yes, please do - practical confirmation more convincing than my certainty.

Indeed, I am no longer be able to reproduce this anymore.

