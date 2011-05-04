Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 904EC6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 13:28:37 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p44HSZue001686
	for <linux-mm@kvack.org>; Wed, 4 May 2011 10:28:35 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by hpaq12.eem.corp.google.com with ESMTP id p44HS6gc026598
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 10:28:33 -0700
Received: by pzk35 with SMTP id 35so2236047pzk.25
        for <linux-mm@kvack.org>; Wed, 04 May 2011 10:28:33 -0700 (PDT)
Date: Wed, 4 May 2011 10:28:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH resend] mm: get rid of CONFIG_STACK_GROWSUP ||
 CONFIG_IA64
In-Reply-To: <20110504083005.GA1375@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1105041016110.23159@sister.anvils>
References: <20110503141044.GA25351@tiehlicka.suse.cz> <alpine.LSU.2.00.1105031142260.7349@sister.anvils> <20110504083005.GA1375@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 4 May 2011, Michal Hocko wrote:
> 
> This case is obscure enough already because we are using VM_GROWSUP to
> declare expand_stack_upwards in include/linux/mm.h

Ah yes, I didn't notice that it was already done that way there
(closer to the definitions of VM_GROWSUP so not as bad).

> while definition is guarded by CONFIG_STACK_GROWSUP||CONFIG_IA64. 
> What the patch does is just "make it consistent" thing. I think we
> should at least use CONFIG_STACK_GROWSUP||CONFIG_IA64 at both places if
> you do not like VM_GROWSUP misuse.

If it's worth changing anything, yes, that would be better.

> 
> > Not a nack: others may well disagree with me.
> > 
> > And, though I didn't find time to comment on your later "symmetrical"
> > patch before it went into mmotm, I didn't see how renaming expand_downwards
> > and expand_upwards to expand_stack_downwards and expand_stack_upwards was
> > helpful either - needless change, and you end up using expand_stack_upwards
> > on something which is not (what we usually call) the stack.
> 
> OK, I see your point. expand_stack_upwards in ia64_do_page_fault can be
> confusing as well. Maybe if we stick with the original expand_upwards
> and just make expand_downwards symmetrical without renameing to
> "_stack_" like the patch does? I can rework that patch if there is an
> interest. I would like to have it symmetrical, though, because the
> original code was rather confusing.

Yes, what I suggested before was an expand_upwards, an expand_downwards
and an expand_stack (with mod to fs/exec.c to replace its call to
expand_stack_downwards by direct call to expand_downwards).

But it's always going to be somewhat confusing and asymmetrical
because of the ia64 register backing store case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
