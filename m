Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id E5EB66B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 21:49:35 -0500 (EST)
Received: by dadv6 with SMTP id v6so31649dad.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 18:49:35 -0800 (PST)
Date: Thu, 8 Mar 2012 10:54:52 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: Fine granularity page reclaim
Message-ID: <20120308025452.GA6196@gmail.com>
References: <20120217092205.GA9462@gmail.com>
 <4F3EB675.9030702@openvz.org>
 <20120220062006.GA5028@gmail.com>
 <4F41F1C2.3030908@openvz.org>
 <CANWLp03njY11Swiic7_mv6Gk3C=v4YYe5nLzbAjLH0KftyQftA@mail.gmail.com>
 <4F57C610.8050101@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F57C610.8050101@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Mar 08, 2012 at 12:33:20AM +0400, Konstantin Khlebnikov wrote:
> Zheng Liu wrote:
> >
> >
> >On Monday, February 20, 2012, Konstantin Khlebnikov <khlebnikov@openvz.org <mailto:khlebnikov@openvz.org>> wrote:
> > > Zheng Liu wrote:
> > >>
> > >> Cc linux-kernel mailing list.
> > >>
> > >> On Sat, Feb 18, 2012 at 12:20:05AM +0400, Konstantin Khlebnikov wrote:
> > >>>
> > >>> Zheng Liu wrote:
> > >>>>
> > >>>> Hi all,
> > >>>>
> > >>>> Currently, we encounter a problem about page reclaim. In our product system,
> > >>>> there is a lot of applictions that manipulate a number of files. In these
> > >>>> files, they can be divided into two categories. One is index file, another is
> > >>>> block file. The number of index files is about 15,000, and the number of
> > >>>> block files is about 23,000 in a 2TB disk. The application accesses index
> > >>>> file using mmap(2), and read/write block file using pread(2)/pwrite(2). We hope
> > >>>> to hold index file in memory as much as possible, and it works well in Redhat
> > >>>> 2.6.18-164. It is about 60-70% of index files that can be hold in memory.
> > >>>> However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that the
> > >>>> linux uses an active list and an inactive list to handle page reclaim, and in
> > >>>> 2.6.32 that they are divided into anonymous list and file list. So I am
> > >>>> curious about why most of index files can be hold in 2.6.18? The index file
> > >>>> should be replaced because mmap doesn't impact the lru list.
> > >>>
> > >>> There was my patch for fixing similar problem with shared/executable mapped pages
> > >>> "vmscan: promote shared file mapped pages" commit 34dbc67a644f and commit c909e99364c
> > >>> maybe it will help in your case.
> > >>
> > >> Hi Konstantin,
> > >>
> > >> Thank you for your reply.  I have tested it in upstream kernel.  These
> > >> patches are useful for multi-processes applications.  But, in our product
> > >> system, there are some applications that are multi-thread.  So
> > >> 'references_ptes>  1' cannot help these applications to hold the data in
> > >> memory.
> > >
> > > Ok, what if you mmap you data as executable, just to test.
> > > Then these pages will be activated after first touch.
> > > In attachment patch with per-mm flag with the same effect.
> > >
> >
> >Hi Konstantin,
> >
> >Sorry for the delay reply.  Last two weeks I was trying these two solutions
> >and evaluating the impacts for the performance in our product system.
> >Good news is that these two solutions both work well. They can keep
> >mapped files in memory under mult-thread.  But I have a question for
> >the first solution (map the file with PROT_EXEC flag).  I think this way is
> >too tricky.  As I said previously, these files that needs to be mapped only
> >are normal index file, and they shouldn't be mapped with PROT_EXEC flag
> >from the view of an application programmer.  So actually the key issue is
> >that we should provide a mechanism, which lets different file sets can be
> >reclaimed separately.  I am not sure whether this idea is useful or not.  So
> >any feedbacks are welcomed.:-).  Thank you.
> >
> 
> Sounds good. Yes, PROT_EXEC isn't very usable and secure, per-mm flag not
> very flexible too. I prefer setting some kind of memory pressure priorities
> for each vma and inode. Probably we can sort vma and inodes into different
> cgroup-like sets and balance memory pressure between them.
> Maybe someone was thought about it...

Thanks for your advices.  About setting pressure priorities for each vma
and inode, I will send a new mail to mailing list to discuss this
problem.  Maybe someone has some good ideas for it. ;-)

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
