Subject: Re: Fairness in love and swapping
References: <199802252032.UAA01920@dax.dcs.ed.ac.uk> 	<199802260805.JAA00715@cave.BitWizard.nl> <199802262233.WAA03878@dax.dcs.ed.ac.uk>
From: "Michael O'Reilly" <michael@metal.iinet.net.au>
Date: 27 Feb 1998 10:56:01 +0800
In-Reply-To: "Stephen C. Tweedie"'s message of Thu, 26 Feb 1998 22:33:28 GMT
Message-ID: <x7hg5l92ny.fsf@metal.iinet.net.au>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rogier Wolff <R.E.Wolff@BitWizard.nl>, torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@dcs.ed.ac.uk> writes:
> > What we really need is that some mechanism that actually determines
> > in the first and last case that the system is thrashing like hell,
> > and that "swapping" (as opposed to paging) is becoming a required
> > strategy. 
> 
> True.  Any takers for this?  :)
> 

That should be fairly easy. A stab. If the MIN(page in rate, page out
rate) over the last 30 seconds(?) is greater than X, and there are
more than 2(?) processes involved, then start swapping (instead of
paging).

Taking a relatively long baseline means that you need a lot of paging
to trigger. Taking the min of in/out means that it isn't just a
growing process, but something with a working set that's larger than
available ram. Taking the dispertion means that you ignore just one
process running out of ram.

Comments?

The tricky bit there is working out how many processes are
involved. Maybe something as simple as a circular log N elements long
that records the last PID associated with the last page out/in.

This is cheap for the page case, and then you can regularly poll the
rates to check.





int pid_log[N];
int pid_log_next;

page_out/page_in()
	.....
	
	pid_log[pid_log_next] = pid;
	pid_log_next = (pid_log_next+1)&(N-1);

	++page_rate_in;
	....


check_page_rates()
	
	age page rates;
	dispertion = number of different PID's in log;

	if MIN(page_rate_in, page_rate_out) > blah &&
		dispertion > 3) {
		swapping = 1;
	} else {
		swapping = 0;
	}
	...
