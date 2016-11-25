Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 883736B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 15:36:36 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id o141so29920584lff.7
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 12:36:36 -0800 (PST)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id 68si21719854ljf.14.2016.11.25.12.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 12:36:35 -0800 (PST)
Received: by mail-lf0-x232.google.com with SMTP id b14so57653627lfg.2
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 12:36:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk> <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk> <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk> <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
From: Mike Marshall <hubcap@omnibond.com>
Date: Fri, 25 Nov 2016 15:36:25 -0500
Message-ID: <CAOg9mSS=Kt8mrnuBfvRaoR5j+jh7YQ1R8HKBJgGX8zYwSAizrQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

> We do have filesystem code that is just disgusting. As an example:
> fs/afs/ tends to have these crazy "_enter()/_exit()" macros in every
> single function.

Hmmm... we have "gossip" statements in Orangefs which can be triggered with
a debugfs knob... lots of functions have a gossip statement at the
top... is that
disgusting?

-Mike

On Fri, Nov 25, 2016 at 2:51 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Nov 24, 2016 at 11:37 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> My impression is that nobody (at least kernel-side) wants them to be
>> a stable ABI, so long as nobody in userland screams about their code
>> being broken, everything is fine.  As usual, if nobody notices an ABI
>> change, it hasn't happened.  The question is what happens when somebody
>> does.
>
> Right. There is basically _no_ "stable API" for the kernel anywhere,
> it's just an issue of "you can't break workflow for normal people".
>
> And if somebody writes his own trace scripts, and some random trace
> point goes away (or changes semantics), that's easy: he can just fix
> his script. Tracepoints aren't ever going to be stable in that sense.
>
> But when then somebody writes a trace script that is so useful that
> distros pick it up, and people start using it and depending on it,
> then _that_ trace point may well have become effectively locked in
> stone.
>
> That's happened once already with the whole powertop thing. It didn't
> get all that widely spread, and the fix was largely to improve on
> powertop to the point where it wasn't a problem any more, but we've
> clearly had one case of this happening.
>
> But I suspect that something like powertop is fairly unusual. There is
> certainly room for similar things in the VFS layer (think "better
> vmstat that uses tracepoints"), but I suspect the bulk of tracepoints
> are going to be for random debugging (so that developers can say
> "please run this script") rather than for an actual user application
> kind of situation.
>
> So I don't think we should be _too_ afraid of tracepoints either. When
> being too anti-tracepoint is a bigger practical problem than the
> possible problems down the line, the balance is wrong.
>
> As long as tracepoints make sense from a higher standpoint (ie not
> just random implementation detail of the day), and they aren't
> everywhere, they are unlikely to cause much problem.
>
> We do have filesystem code that is just disgusting. As an example:
> fs/afs/ tends to have these crazy "_enter()/_exit()" macros in every
> single function. If you want that, use the function tracer. That seems
> to be just debugging code that has been left around for others to
> stumble over. I do *not* believe that we should encourage that kind of
> "machine gun spray" use of tracepoints.
>
> But tracing actual high-level things like IO and faults? I think that
> makes perfect sense, as long as the data that is collected is also the
> actual event data, and not so much a random implementation issue of
> the day.
>
>              Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
