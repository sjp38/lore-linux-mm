From: Chase Venters <chase.venters@clientec.com>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
Date: Sun, 9 Jul 2006 00:18:22 -0500
References: <BKEKJNIHLJDCFGDBOHGMCEEGDCAA.abum@aftek.com>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMCEEGDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200607090018.45972.chase.venters@clientec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Robert Hancock <hancockr@shaw.ca>, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 08 July 2006 23:23, Abu M. Muttalib wrote:
> Hi,
>
> I tried with the /proc/sys/vm/overcommit_memory=2 and the system refused to
> load the program altogether.
>
> In this scenario is making overcommit_memory=2 a good idea?

(Good mailing list practices ask you not to top-post - that is, make your 
reply text follow the text you are replying other than appearing before it, 
as I demonstrate here:)

Well, how much memory do you have? Does the application actually need more 
memory than your system can provide? If this is the case, there isn't going 
to be any fix except add more memory. Your choices are:

1. Let the OOM killer sacrifice processes because you don't have enough memory
2. Disable VM overcommit so that the OOM killer doesn't get engaged (rather, 
the application's attempt to grab the memory will fail)
3. Add more memory, don't mess with the overcommit sysctl, and watch things 
work nicely :P

Are you sure it's not a memory leak? Does the application work on a freshly 
booted system?

> Regards,
> Abu.

Thanks,
Chase

> -----Original Message-----
> From: Robert Hancock [mailto:hancockr@shaw.ca]
> Sent: Saturday, July 08, 2006 11:36 PM
> To: Abu M. Muttalib
> Cc: kernelnewbies@nl.linux.org; linux-newbie@vger.kernel.org;
> linux-kernel@vger.kernel.org; linux-mm
> Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
>
> Abu M. Muttalib wrote:
> > Hi,
> >
> > I am getting the Out of memory.
> >
> > To circumvent the problem, I have commented the call to "out_of_memory(),
> > and replaced "goto restart" with "goto nopage".
> >
> > At "nopage:" lable I have added a call to "schedule()" and then "return
> > NULL" after "schedule()".
>
> Bad idea - in the configuration you have, the system may need the
> out-of-memory killer to free up memory, otherwise the system can
> deadlock due to all memory being exhausted.
>
> > I tried the modified kernel with a test application, the test application
>
> is
>
> > mallocing memory in a loop. Unlike as expected the process gets killed.
> > On second run of the same application I am getting the page allocation
>
> failure
>
> > as expected but subsequently the system hangs.
> >
> > I am attaching the test application and the log herewith.
> >
> > I am getting this exception with kernel 2.6.13. With kernel
> > 2.4.19-rmka7-pxa1 there was no problem.
> >
> > Why its so? What can I do to alleviate the OOM problem?
>
> Please see Documentation/vm/overcommit-accounting in the kernel source
> tree.
>
> --
> Robert Hancock      Saskatoon, SK, Canada
> To email, remove "nospam" from hancockr@nospamshaw.ca
> Home Page: http://www.roberthancock.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
