Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB09E6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:36 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so44708243wmd.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si2742236wma.160.2017.01.26.03.58.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 03:58:35 -0800 (PST)
Date: Thu, 26 Jan 2017 12:58:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170126115833.GI6590@dhcp22.suse.cz>
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
 <588907AA.1020704@iogearbox.net>
 <20170126074354.GB8456@dhcp22.suse.cz>
 <5889C331.7020101@iogearbox.net>
 <20170126100802.GF6590@dhcp22.suse.cz>
 <5889DEA3.7040106@iogearbox.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5889DEA3.7040106@iogearbox.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On Thu 26-01-17 12:33:55, Daniel Borkmann wrote:
> On 01/26/2017 11:08 AM, Michal Hocko wrote:
[...]
> > If you disagree I can drop the bpf part of course...
> 
> If we could consolidate these spots with kvmalloc() eventually, I'm
> all for it. But even if __GFP_NORETRY is not covered down to all
> possible paths, it kind of does have an effect already of saying
> 'don't try too hard', so would it be harmful to still keep that for
> now? If it's not, I'd personally prefer to just leave it as is until
> there's some form of support by kvmalloc() and friends.

Well, you can use kvmalloc(size, GFP_KERNEL|__GFP_NORETRY). It is not
disallowed. It is not _supported_ which means that if it doesn't work as
you expect you are on your own. Which is actually the situation right
now as well. But I still think that this is just not right thing to do.
Even though it might happen to work in some cases it gives a false
impression of a solution. So I would rather go with
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8697f43cf93c..a6dc4d596f14 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -53,6 +53,11 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
 
 void *bpf_map_area_alloc(size_t size)
 {
+	/*
+	 * FIXME: we would really like to not trigger the OOM killer and rather
+	 * fail instead. This is not supported right now. Please nag MM people
+	 * if these OOM start bothering people.
+	 */
 	return kvzalloc(size, GFP_USER);
 }
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
