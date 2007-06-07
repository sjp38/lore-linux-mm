Date: Thu, 7 Jun 2007 11:20:04 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
Message-ID: <20070607162004.GA27802@vino.hallyn.com>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com> <20070606204432.b670a7b1.akpm@linux-foundation.org> <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <acahalan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, pbadari@us.ibm.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Quoting Albert Cahalan (acahalan@gmail.com):
> On 6/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >On Wed, 6 Jun 2007 23:27:01 -0400 "Albert Cahalan" <acahalan@gmail.com> 
> >wrote:
> >> Eric W. Biederman writes:
> >> > Badari Pulavarty <pbadari@us.ibm.com> writes:
> >>
> >> >> Your recent cleanup to shm code, namely
> >> >>
> >> >> [PATCH] shm: make sysv ipc shared memory use stacked files
> >> >>
> >> >> took away one of the debugging feature for shm segments.
> >> >> Originally, shmid were forced to be the inode numbers and
> >> >> they show up in /proc/pid/maps for the process which mapped
> >> >> this shared memory segments (vma listing). That way, its easy
> >> >> to find out who all mapped this shared memory segment. Your
> >> >> patchset, took away the inode# setting. So, we can't easily
> >> >> match the shmem segments to /proc/pid/maps easily. (It was
> >> >> really useful in tracking down a customer problem recently).
> >> >> Is this done deliberately ? Anything wrong in setting this back ?
> >> >
> >> > Theoretically it makes the stacked file concept more brittle,
> >> > because it means the lower layers can't care about their inode
> >> > number.
> >> >
> >> > We do need something to tie these things together.
> >> >
> >> > So I suspect what makes most sense is to simply rename the
> >> > dentry SYSVID<segmentid>
> >>
> >> Please stop breaking things in /proc. The pmap command relys
> >> on the old behavior.
> >
> >What effect did this change have upon the pmap command?  Details, please.
> >
> >> It's time to revert.
> >
> >Probably true, but we'd need to understand what the impact was.
> 
> Very simply, pmap reports the shmid.
> 
> albert 0 ~$ pmap `pidof X` | egrep -2 shmid
> 30050000  16384K rw-s-  /dev/fb0
> 31050000    152K rw---    [ anon ]
> 31076000    384K rw-s-    [ shmid=0x3f428000 ]
> 310d6000    384K rw-s-    [ shmid=0x3f430001 ]
> 31136000    384K rw-s-    [ shmid=0x3f438002 ]
> 31196000    384K rw-s-    [ shmid=0x3f440003 ]
> 311f6000    384K rw-s-    [ shmid=0x3f448004 ]
> 31256000    384K rw-s-    [ shmid=0x3f450005 ]
> 312b6000    384K rw-s-    [ shmid=0x3f460006 ]
> 31316000    384K rw-s-    [ shmid=0x3f870007 ]
> 31491000    140K r----  /usr/share/fonts/type1/gsfonts/n021003l.pfb
> 3150e000   9496K rw---    [ anon ]

Ok, so IIUC the problem was that inode->i_ino was being set to the id,
and the id can be the same for different things in two namespaces.

So aside from not using the id as inode->i_ino, an alternative is to use
a separate superblock, spearate mqeueue fs, for each ipc ns.

I haven't looked at that enough to see whether it's feasible, i.e. I 
don't know what else mqueue fs is used for.  Eric, does that sound
reasonable to you?

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
