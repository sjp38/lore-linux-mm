From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911011700.JAA70685@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm21-2.3.23 alow larger sizes to shmget()
Date: Mon, 1 Nov 1999 09:00:15 -0800 (PST)
In-Reply-To: <qwwaeoyk0qi.fsf@sap.com> from "Christoph Rohland" at Nov 1, 99 10:41:25 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi Kanoj,
> 
> This is probably breaking user space applications since shmid_ds is
> shared with user space in shmctl(2).  On 32bit machines this does not
> matter, since sizeof(int) == sizeof(size_t), but on 64bit this will
> break.
> 
> How do we handle this?

Unfortunately, I don't think we can prevent this 64bit ABI breakage, if
we want to conform to the single unix spec on those platforms. Its 
probably a good idea to have the ia64 port be SUS compliant, even though
sparc64/alpha are currently not. 

If it is really important to preserve the 64bit ABI, there's one more 
alternative: preserve the shmget() api/abi on the old 64bit platforms, but
be compliant on the 32 bit ones and newer 64 bit ones (mips64/ia64). This 
is not the cleanest solution, but can be done with a little header file
reorganization in include/linux/shm.h and include/linux/shmparam.h.

Linus has put this patch into pre-25, lets talk if it is important to
do the above ... it shouldn't take me more than a couple of hours to 
do it, if we so decided.

Thanks.

Kanoj

> 
> Greetings
>          Christoph
> 
> kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> 
> > Linus,
> > 
> > Per our previous discussion, this is the patch to change the shmget()
> > api to permit larger shm segments (now that larger user address spaces,
> > as well as large memory machines are possible).
> > 
> > Note that I have defined shmget() as
> > 	shmget(key_t, size_t, int)
> > instead of as
> > 	shmget(key_t, unsigned int, int)
> > or as
> > 	shmget(key_t, unsigned long, int).
> > 
> > This is because the single unix spec sets down the first definition
> > (http://www.opengroup.org/onlinepubs/007908799/xsh/shmget.html).
> > This becomes interesting, because size_t is of different sizes on
> > different architectures, so the shmfs code has to do careful formatting.
> > (This logic is also probably needed in the ipcs command).
> > 
> > Let me know if the patch looks okay.
> > 
> > Thanks.
> > 
> > Kanoj
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
