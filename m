Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 11D3A6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 19:30:22 -0400 (EDT)
Received: by igr7 with SMTP id 7so135798002igr.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 16:30:21 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id a5si56702179pat.91.2015.07.28.16.30.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 16:30:21 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so79666698pdj.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 16:30:21 -0700 (PDT)
Date: Tue, 28 Jul 2015 16:30:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: hugetlb pages not accounted for in rss
In-Reply-To: <20150728222654.GA28456@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
References: <55B6BE37.3010804@oracle.com> <20150728183248.GB1406@Sligo.logfs.org> <55B7F0F8.8080909@oracle.com> <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com> <20150728222654.GA28456@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-632582589-1438126220=:10368"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-632582589-1438126220=:10368
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 28 Jul 2015, Jorn Engel wrote:

> What would you propose for me then?  I have 80% RAM or more in reserved
> hugepages.  OOM-killer is not a concern, as it panics the system - the
> alternatives were almost universally silly and we didn't want to deal
> with system in unpredictable states.  But knowing how much memory is
> used by which process is a concern.  And if you only tell me about the
> small (and continuously shrinking) portion, I essentially fly blind.
> 
> That is not a case of "may lead to breakage", it _is_ broken.
> 
> Ideally we would have fixed this in 2002 when hugetlbfs was introduced.
> By now we might have to introduce a new field, rss_including_hugepages
> or whatever.  Then we have to update tools like top etc. to use the new
> field when appropriate.  No fun, but might be necessary.
> 
> If we can get away with including hugepages in rss and fixing the OOM
> killer to be less silly, I would strongly prefer that.  But I don't know
> how much of a mess we are already in.
> 

It's not only the oom killer, I don't believe hugeltb pages are accounted 
to the "rss" in memcg.  They use the hugetlb_cgroup for that.  Starting to 
account for them in existing memcg deployments would cause them to hit 
their memory limits much earlier.  The "rss_huge" field in memcg only 
represents transparent hugepages.

I agree with your comment that having done this when hugetlbfs was 
introduced would have been optimal.

It's always difficult to add a new class of memory to an existing metric 
("new" here because it's currently unaccounted).

If we can add yet another process metric to track hugetlbfs memory mapped, 
then the test could be converted to use that.  I'm not sure if the 
jusitifcation would be strong enough, but you could try.
--397176738-632582589-1438126220=:10368--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
