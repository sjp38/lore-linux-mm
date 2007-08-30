Date: Thu, 30 Aug 2007 11:19:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V4
In-Reply-To: <1188487157.5794.40.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708301116530.7975@schroedinger.engr.sgi.com>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
 <20070827201822.2506b888.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
 <20070827222912.8b364352.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
 <20070827231214.99e3c33f.akpm@linux-foundation.org>  <1188309928.5079.37.camel@localhost>
  <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
 <1188398621.5121.13.camel@localhost>  <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
 <1188487157.5794.40.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Nish Aravamudan <nish.aravamudan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 30 Aug 2007, Lee Schermerhorn wrote:

> Try, try again.  Maybe closer this time.

Yes. Thanks for all your work on this.

> Question:  do we need/want to display the normal and high memory masks
> separately for systems with HIGHMEM?  If not, I'd suggest changing the
> print_nodes_state() function to take a nodemask_t* instead of a state
> enum and expose a single 'has_memory' attribute that we print using
> something like:

No leave it separate.

> 
> static ssize_t print_nodes_has_memory(struct sysdev_class *class,
> 						char *buf)
> {
> 	nodemask_t has_memory = node_states[N_NORMAL_MEMORY];
> 
> 	if (N_HIGH_MEMORY - N_NORMAL_MEMORY)

Uggg. Better do #ifdef CONFIG_HIGHMEM

> 		nodes_or(has_memory, has_memory, node_states[N_HIGH_MEMORY]);
> 
> 	return print_nodes_state(&has_memory, buf);

> + * node states attributes
> + */
> +
> +static ssize_t print_nodes_state(enum node_states state, char *buf)
> +{
> +	int n;
> +
> +	n = nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
> +	if (n <= 0)
> +		goto done;
> +	if (PAGE_SIZE - n > 1) {

if (n > 0 && PAGE_SIZE > n + 1)

?
> +		*(buf + n++) = '\n';
> +		*(buf + n++) = '\0';
> +	}

> +static ssize_t print_nodes_possible(struct sysdev_class *class, char *buf)
> +{
> +	return print_nodes_state(N_POSSIBLE, buf);
> +}
> +
> +static ssize_t print_nodes_online(struct sysdev_class *class, char *buf)
> +{
> +	return print_nodes_state(N_ONLINE, buf);
> +}
> +
> +static ssize_t print_nodes_has_normal_memory(struct sysdev_class *class,
> +						char *buf)
> +{
> +	return print_nodes_state(N_NORMAL_MEMORY, buf);
> +}
> +
> +static ssize_t print_nodes_has_cpu(struct sysdev_class *class, char *buf)
> +{
> +	return print_nodes_state(N_CPU, buf);
> +}
> +
> +static SYSDEV_CLASS_ATTR(possible, 0444, print_nodes_possible, NULL);
> +static SYSDEV_CLASS_ATTR(online, 0444, print_nodes_online, NULL);
> +static SYSDEV_CLASS_ATTR(has_normal_memory, 0444, print_nodes_has_normal_memory,

I am sure that there is some way to dynamicall allocate these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
