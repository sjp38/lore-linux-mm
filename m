Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 491E46B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 13:09:52 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q197so429221iod.17
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 10:09:52 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id z7si12054134itd.151.2018.03.08.10.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 10:09:51 -0800 (PST)
Date: Thu, 8 Mar 2018 12:09:49 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix misleading 'age' in verbose slub prints
In-Reply-To: <da1be252-403f-6725-a1b8-223222f7f946@codeaurora.org>
Message-ID: <alpine.DEB.2.20.1803081204230.14628@nuc-kabylake>
References: <1520423266-28830-1-git-send-email-cpandya@codeaurora.org> <alpine.DEB.2.20.1803071212150.6373@nuc-kabylake> <20180307182212.GA23411@bombadil.infradead.org> <da1be252-403f-6725-a1b8-223222f7f946@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Matthew Wilcox <willy@infradead.org>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Mar 2018, Chintan Pandya wrote:

> > If you print the raw value, then you can do the subtraction yourself;
> > if you've subtracted it from jiffies each time, you've at least introduced
> > jitter, and possibly enough jitter to confuse and mislead.
> >
> This is exactly what I was thinking. But looking up 'age' is easy compared to
> 'when' and this seems required as from Christopher's
> reply. So, will raise new patch cleaning commit message a bit.

Well then you need to provide some sort of log text processor I think.
Otherwise you need to get the object address from the log message, then
scan back through the log to find the correct allocation entry, retrieve
both jiffy values and subtract them. If the age is there then you can
simply see how far in the past the object was allocated.

One advantage in favor of jiffies would be the ability to correlate
multiple events if each log line would have a jiffies like timestamps.

But it does not. So I think outputting jiffies there is causing more
problems that benefits.
