Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 74D6D6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:46:09 -0400 (EDT)
Date: Fri, 28 Jun 2013 10:00:27 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628100027.31504abe@redhat.com>
In-Reply-To: <20130628050712.GA10097@teo>
References: <20130626231712.4a7392a7@redhat.com>
	<20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
	<20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, 27 Jun 2013 22:07:12 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Thu, Jun 27, 2013 at 09:34:11PM -0700, Anton Vorontsov wrote:
> > ... we can add the strict mode and deprecate the
> > "filtering" -- basically we'll implement the idea of requiring that
> > userspace registers a separate fd for each level.
> 
> Btw, assuming that more levels can be added, there will be a problem:
> imagine that an app hooked up onto low, med, crit levels in "strict"
> mode... then once we add a new level, the app will start missing the new
> level events.

That's how it's expected to work, because on strict mode you're notified
for the level you registered for. So apps registering for critical, will
still be notified on critical just like before.

> In the old scheme it is not a problem because of the >= condition.

I think the problem actually lies with the current interface, because
if an app registers for critical and we add a new level after critical
then this app will now be notified on critical *and* the new level. The
app's algorithm might not be prepared to deal with that.

> With a proper versioning this won't be a problem for a new scheme too.

I don't think there's a problem to be solved here. Strict mode does
allow forward compatibility. For good backward compatibility we can make
memory.pressure_level return supported levels on read. This way
applications can check if the level they are interested in exist and
then fallback or exit with a good error message if they don't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
