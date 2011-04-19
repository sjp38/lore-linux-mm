Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 110CD8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:10:10 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:10:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
Message-ID: <20110419111004.GE21689@tiehlicka.suse.cz>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
 <20110418100131.GD8925@tiehlicka.suse.cz>
 <20110418135637.5baac204.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110418135637.5baac204.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org

On Mon 18-04-11 13:56:37, Andrew Morton wrote:
> On Mon, 18 Apr 2011 12:01:31 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Currently we have expand_upwards exported while expand_downwards is
> > accessible only via expand_stack or expand_stack_downwards.
> > 
> > check_stack_guard_page is a nice example of the asymmetry. It uses
> > expand_stack for VM_GROWSDOWN while expand_upwards is called for
> > VM_GROWSUP case.
> > 
> > Let's clean this up by exporting both functions and make those name
> > consistent. Let's use expand_stack_{upwards,downwards} so that we are
> > explicit about stack manipulation in the name. expand_stack_downwards
> > has to be defined for both CONFIG_STACK_GROWS{UP,DOWN} because
> > get_arg_page calls the downwards version in the early process
> > initialization phase for growsup configuration.
> 
> Has this patch been tested on any stack-grows-upwards architecture?

The only one I can find in the tree is parisc and I do not have access
to any such machine. Maybe someone on the list (CCed) can help with
testing the patch bellow? Nevertheless, the patch doesn't change growsup
case. It just renames functions and exports growsdown.

IA64 which grows upwards only for registers still needs a fix because of
the rename, though. I'm sorry, I must have missed it in the grep output
before. No other arch specific code uses expand_{down,up}wards directly.

Changes since v2
 - fix compilation error on ia64
Changes since v1
 - fixed expand_downwards case for CONFIG_STACK_GROWSUP in get_arg_page.
 - rename expand_{downwards,upwards} -> expand_stack_{downwards,upwards}
--- 
