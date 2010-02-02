Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1E61E6B0088
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 16:10:12 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Tue, 2 Feb 2010 22:10:06 +0100
References: <201002012302.37380.l.lunak@suse.cz> <alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002022210.06760.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Tuesday 02 of February 2010, David Rientjes wrote:
> On Mon, 1 Feb 2010, Lubos Lunak wrote:
> >  Hello,

> I don't quite understand how you can say the oom killer is "completely
> useless and harmful."  It certainly fulfills its purpose, which is to kill
> a memory hogging task so that a page allocation may succeed when reclaim
> has failed to free any memory.

 I started the sentence with "here". And if you compare my description of what 
happens with the 5 goals listed in oom_kill.c, you can see that it fails all 
of them except for 2, and even in that case it is much better to simply 
reboot the computer. So that is why OOM killer _here_ is completely useless 
and harmful, as even panic_on_oom does a better job.

 I'm not saying it's so everywhere, presumably it works somewhere when 
somebody has written it this way, but since some of the design decisions 
appear to be rather poor for desktop systems, "here" is probably not really 
limited only to my computer either.

> >  The process tree looks roughly like this:
> >
> > init
> >   |- kdeinit
> >   |  |- ksmserver
> >   |  |  |- kwin
> >   |  |- <other>
> >   |- konsole
> >      |- make
> >         |- sh
> >         |  |- meinproc4
> >         |- sh
> >         |  |- meinproc4
> >         |- <etc>
> >
> >  What happens is that OOM killer usually selects either ksmserver (KDE
> > session manager) or kdeinit (KDE master process that spawns most KDE
> > processes). Note that in either case OOM killer does not reach the point
> > of killing the actual offender - it will randomly kill in the tree under
> > kdeinit until it decides to kill ksmserver, which means terminating the
> > desktop session. As konsole is a KUniqueApplication, it forks into
> > background and gets reparented to init, thus getting away from the
> > kdeinit subtree. Since the memory pressure is distributed among several
> > meinproc4 processes, the badness does not get summed up in its make
> > grandparent, as badness() does this only for direct parents.
>
> There's no randomness involved in selecting a task to kill;

 That was rather a figure of speech, but even if you want to take it 
literally, then from the user's point of view it is random. Badness of 
kdeinit depends on the number of children it has spawned, badness of 
ksmserver depends for example on the number and size of windows open (as its 
child kwin is a window and compositing manager).

 Not that it really matters - the net result is that OOM killer usually 
decides to kill kdeinit or ksmserver, starts killing their children, vital 
KDE processes, and since the offenders are not among them, it ends up either 
terminating the whole session by killing ksmserver or killing enough vital 
processes there to free enough memory for the offenders to finish their work 
cleanly.

> The process tree that you posted shows a textbook case for using
> /proc/pid/oom_adj to ensure a critical task, such as kdeinit is to you, is
> protected from getting selected for oom kill.  In your own words, this
> "spawns most KDE processes," so it's an ideal place to set an oom_adj
> value of OOM_DISABLE since that value is inheritable to children and,
> thus, all children are implicitly protected as well.

 Yes, it's a textbook case, sadly textbook cases are theory and not practice. 
I didn't mention it in my first mail to keep it shorter, but we have actually 
tried it. First of all, it's rather cumbersome - as it requires root 
priviledges, there is one wrapped needed for setuid and another one to avoid 
setuid side-effects, moreover the setuid root process needs to stay running 
and unset the protection on all children, or it'd be useless again.

 Worse, it worked for about a year or two and now it has only shifted the 
problem elsewhere and that's it. We now protect kdeinit, which means the OOM 
killer's choice will very likely ksmserver then. Ok, so let's say now we 
start protecting also ksmserver, that's some additional hassle setting it up, 
but that's doable. Now there's a good chance the OOM killer's choice will be 
kwin (as a compositing manager it can have quite large mappings because of 
graphics drivers). So ok, we need to protect the window manager, but since 
that's not a hardcoded component like ksmserver, that's even more hassle.

 And, after all that, OOM killer will simply detect yet another innocent 
process. I didn't mention that, but the memory statistics I presented for one 
selected KDE process in my original mail were actually for an ordinary KDE 
application - Konqueror showing a web page. Yet, as you can read in my 
original mail, even though it used only about half memory of what the 
offender used, it still scored almost tripple of its badness score.

 So unless you would suggest I implement my own dynamic badness handling in 
userspace, which I hope we can all agree is nonsense, then oom_adj is a 
cumbersome non-solution here. It may work in some setups, but it doesn't for 
the desktop.

> Using VmSize, however, allows us to define the most important task to kill
> for the oom killer: memory leakers.  Memory leakers are the single most
> important tasks to identify with the oom killer and aren't obvious when
> using rss because leaked memory does not stay resident in RAM.  I
> understand your system may not have such a leaker and it is simply
> overcommitted on a 2GB machine, but using rss loses that ability.

 Interesting point. Am I getting it right that you're saying that VmRSS is 
unsuitable because badness should take into account not only the RAM used by 
the process but also the swap space used by the process? If yes, then this 
rather brings up the question why doesn't the badness calculation then do it 
and uses VmSize instead?

 I mean, as already demonstrated in the original mail, VmSize clearly can be 
very wrong as a representation of memory used. I would actually argue that 
VmRSS is still better, as the leaker would eventually fill the swap and start 
taking up RAM, but either way, how about this then?

-       points = mm->total_vm;
+       points = get_mm_rss(mm) + 
get_mm_space_used_in_swap_but_not_in_other_places_like_file_backing(mm);

 (I don't know if there's a function doing the latter or how to count it. 
Probably not exactly trivial given that I have experience 
with /proc/*/stat*-using tools like top reporting rather wrong numbers for 
swap usage of processes.)

> It also makes tuning oom killer priorities with /proc/pid/oom_adj almost
> impossible since a task's rss is highly dynamic and we cannot speculate on
> the state of the VM at the time of oom.

 I see. However using VmRSS and swap space together avoids this.

> >  In other words, use VmRSS for measuring memory usage instead of VmSize,
> > and remove child accumulating.
> >
> >  I hope the above is good enough reason for the first change. VmSize
> > includes things like read-only mappings, memory mappings that is actually
> > unused, mappings backed by a file, mappings from video drivers, and so
> > on. VmRSS is actual real memory used, which is what mostly matters here.
> > While it may not be perfect, it is certainly an improvement.
>
> It's not for a large number of users,

 You mean, besides all desktop users? In my experience desktop machines start 
getting rather useless when their swap usage starts nearing the total RAM 
amount, so swap should not be that significant. Moreover, again, it's still 
better than VmSize, which can be wildly inaccurate. On my desktop system it 
definitely is.

 Hmm, maybe you're thinking server setup and that's different, I don't know. 
Does the kernel have any "desktop mode"? I wouldn't mind if VmSize was used 
on servers if you insist it is better, but on desktop VmSize is just plain 
wrong. And, again, I think VmRSS+InSwap is better then either.

> the consumer of the largest amount 
> of rss is not necessarily the task we always want to kill.  Just because
> an order-0 page allocation fails does not mean we want to kill the task
> that would free the largest amount of RAM.

 It's still much better than killing the task that would free the largest 
amount of address space. And I cannot think of any better metric than 
VmRSS+InSwap. Can you?

> I understand that KDE is extremely important to your work environment and
> if you lose it, it seems like a failure of Linux and the VM.  However, the
> kernel cannot possibly know what applications you believe to be the most
> important.  For that reason, userspace is able to tune the badness() score
> by writing to /proc/pid/oom_adj as I've suggested you do for kdeinit.  You
> have the ability to protect KDE from getting oom killed, you just need to
> use it.

 As already explained, I can't. Besides, I'm not expecting a miracle, I simply 
expect the kernel to kill the process that takes up the most memory, and the 
kernel can possibly know that, it just doesn't do it. What other evidence do 
you want to be shown that badness calculated for two processes on their 
actual memory usage differs by a multiple of 5 or more?

[snipped description of how oom_adj should help when it in fact wouldn't]

> >  I also have problems finding a case where the child accounting would
> > actually help. I mean, in practice, I can certainly come up with
> > something in theory, and this looks to me like a solution to a very
> > synthesized problem. In which realistic case will one process launch a
> > limited number of children, where all of them will consume memory, but
> > just killing the children one by one won't avoid the problem reasonably?
> > This is unlikely to avoid a forkbomb, as in that case the number of
> > children will be the problem. It is not necessary for just one children
> > misbehaving and being restarted, nor will it work there. So what is that
> > supposed to fix, and is it more likely than the case of a process
> > launching several unrelated children?
>
> Right, I believe Kame is working on a forkbomb detector that would replace
> this logic.

 Until then, can we dump the current code? Because I have provided one case 
where it makes things worse and nobody has provided any case where it makes 
things better or any other justification for its existence. There's no point 
in keeping code for which nobody knows how it improves things (in reality, 
not some textbook case).

 And, in case the justification for it is something like "Apache", can we 
fast-forward to my improved suggestion to limit this only to children that 
are forked but not exec()-ed?

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
