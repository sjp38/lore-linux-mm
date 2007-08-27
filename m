Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708271203170.4667@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <1188236904.5952.72.camel@localhost>
	 <Pine.LNX.4.64.0708271203170.4667@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 27 Aug 2007 16:08:53 -0400
Message-Id: <1188245333.5952.84.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-27 at 12:11 -0700, Christoph Lameter wrote:
> On Mon, 27 Aug 2007, Lee Schermerhorn wrote:
> 
> > Works on my numa platform:  4 nodes with cpus, one memory only node.
> > 
> > Questions:
> > 
> > 1)  if this is useful, do we need/want the possible mask?
> 
> Yes that is important for software that wants to allocate per node 
> structures. The possible mask shows which nodes could be activated later.

Good point.  Given that, I'm thinking we might want to limit the
displayed masks--even the internal value of the mask--to something
closer to what a particular platform architecture can support, even tho'
the kernel might be configured for a much larger number.  I'll have to
look into how to do this.

> 
>  > 2)  how about teaching nodemask_scnprintf() to suppress leading
> >     words of all zeros?
> 
> Leading words of all zeroes? nodemask_scnprintf calls bitmap_scnprintf(). 
> Maybe it should call bitmap_scnlistprintf() instead?

For platforms with small numbers of possible nodes, that might look
nicer.  

> 
> 
> > +static ssize_t
> > +print_node_states(struct class *class, char *buf)
> > +{
> > +	int i;
> > +	int n;
> > +	size_t  size = PAGE_SIZE;
> > +	ssize_t len = 0;
> 
> The size varies? Isnt the len enough. Maybe just using one variable would 
> simplify the code?

'size' is used as the remaining amount of space in the buffer for each
subsequent snprintf()-like call.  But, yeah, I can just decrement size
after each call and at the end, subtract it from the original buffer
size--i.e., PAGE_SIZE--to get the length.  Next respin.

> 
> > +
> > +	for (i=0; i < NR_NODE_STATES; ++i) {
> 
> Missing blanks around assignment. 

OK.

> Please use i++.

Sure.  Old habits die hard.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
