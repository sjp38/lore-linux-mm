Message-Id: <199802260805.JAA00715@cave.BitWizard.nl>
Subject: Re: Fairness in love and swapping
Date: Thu, 26 Feb 1998 09:05:55 +0100 (MET)
In-Reply-To: <199802252032.UAA01920@dax.dcs.ed.ac.uk> from "Stephen C. Tweedie" at Feb 25, 98 08:32:02 pm
From: R.E.Wolff@BitWizard.nl (Rogier Wolff)
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> I noticed something rather unfortunate when starting up two of these
> tests simultaneously, each test using a bit less than total physical
> memory.  The first test gobbled up the whole of ram as expected, but the
> second test did not.  What happened was that the contention for memory
> was keeping swap active all the time, but the processes which were
> already all in memory just kept running at full speed and so their pages
> all remained fresh in the page age table.  The newcomer processes were
> never able to keep a page in memory long enough for their age to compete
> with the old process' pages, and so I had a number of identical
> processes, half of which were fully swapped in and half of which were
> swapping madly.
> 
> Needless to say, this is highly unfair, but I'm not sure whether there
> is any easy way round it --- any clock algorithm will have the same
> problem, unless we start implementing dynamic resident set size limits.

[ Processes P1 and P2 both need the same amount of CPU time, I've noted
the "completion percentages" at the top. ]

If you run it like this, you'll get:

          0        50       100
      P1  <---- in memory ----> 

          0                   5         50      100
      P2  < swapping like mad ><---- in memory ---> 

If you'd have enough memory for two of them you'd get:

          0                  50                100
      P1  <--------------- in memory ------------> 

          0                  50                100
      P2  <--------------- in memory ------------> 


but if the system would be "fair" we would get: 

          0                  5                 10            15
      P1  <------ swapping --- like --- mad ------------------- ....

          0                  5                 10            15
      P2  <------ swapping --- like --- mad ------------------- ....


So.... In some cases, this behaviour is exactly what you want. What we
really need is that some mechanism that actually determines in the
first and last case that the system is thrashing like hell, and that
"swapping" (as opposed to paging) is becoming a required
strategy. That would mean putting a "page-in" ban on each process for
relatively long stretches of time. These should become longer with
each time that it occurs. That way, you will get:

          0        50           51      100
      P1  <in memory>...........<in memory> 

          0          1        50           51      100
      P2  ...........<in memory>...........<in memory> 


By making the periods longer, you will cater for larger machines where
getting the working set into main memory might take a long time (think
about a machine with 4G core, and a disk subsystem that reaches 4Mb (*)
per second on "random access paging". That's a quarter of an hour
worth of swapping before that 3.6G process is swapped in....)

Regards,

		Roger Wolff. 



(*) That's about 10 fast disks in parallel. (**)

(**) But keeping 10 disks busy in this case is impossible: Your
process (who "knows" what the next block will be) blocks until the
block is paged in.... 

-- 
If it's there and you can see it, it's REAL      |___R.E.Wolff@BitWizard.nl  |
If it's there and you can't see it, it's TRANSPARENT |  Tel: +31-15-2137555  |
If it's not there and you can see it, it's VIRTUAL   |__FAX:_+31-15-2138217  |
If it's not there and you can't see it, it's GONE! -- Roy Wilks, 1983  |_____|
