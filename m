Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6D4DA6B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:34:58 -0500 (EST)
Date: Fri, 11 Jan 2013 08:34:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Fix wrong EOF compare
Message-ID: <20130110233456.GB2470@blaptop>
References: <1357797904-11194-1-git-send-email-minchan@kernel.org>
 <xa1ta9shm531.fsf@mina86.com>
 <50EEE868.70705@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50EEE868.70705@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>

Hi Randy,

On Thu, Jan 10, 2013 at 08:12:24AM -0800, Randy Dunlap wrote:
> On 01/10/13 07:26, Michal Nazarewicz wrote:
> > On Thu, Jan 10 2013, Minchan Kim <minchan@kernel.org> wrote:
> >> getc returns "int" so EOF could be -1 but storing getc's return
> >> value to char directly makes the vaule to 255 so below condition
> >> is always false.
> > 
> > Technically, this is implementation defined and I believe on many
> > systems char is signed thus the loop will end on EOF or byte 255.
> > 
> > Either way, my point is the patch is correct, but the comment is not. ;)
> 
> and change spelling of 'vaule' to 'value'

Oops. It was typo when I cooked the patch after testing in my ARM system.

> and test build it please.

Keep in mind. Thanks!

> 
> > 
> > Of course, even better if the function just used fgets(), ie. something
> > like:
> > 
> > int read_block(char *buf, int buf_size, FILE *fin)
> > {
> > 	char *curr = buf, *const buf_end = buf + buf_size;
> > 
> > 	while (buf_end - curr > 1 && fgets(curr, buf_end - curr, fin)) {
> > 		if (*curr == '\n') /* empty line */
> > 			return curr - buf;
> > 		curr += strlen(curr);
> > 	}
> > 
> > 	return -1; /* EOF or no space left in buf. */
> > }
> > 
> > which is much shorter and does not have buffer overflow issues.
> > 
> >> It happens in my ARM system so loop is not ended, then segfaulted.
> >> This patch fixes it.
> >>
> >>                 *curr = getc(fin); // *curr = 255
> >>                 if (*curr == EOF) return -1; // if ( 255 == -1)
> >>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Cc: Andy Whitcroft <apw@shadowen.org>
> >> Cc: Alexander Nyberg <alexn@dsv.su.se>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> ---
> >>  Documentation/page_owner.c |    6 ++++--
> >>  1 file changed, 4 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
> >> index f0156e1..b777fb6 100644
> >> --- a/Documentation/page_owner.c
> >> +++ b/Documentation/page_owner.c
> >> @@ -32,12 +32,14 @@ int read_block(char *buf, FILE *fin)
> >>  {
> >>  	int ret = 0;
> >>  	int hit = 0;
> >> +	int vaule;
> >>  	char *curr = buf;
> >>  
> >>  	for (;;) {
> >> -		*curr = getc(fin);
> >> -		if (*curr == EOF) return -1;
> >> +		value = getc(fin);
> >> +		if (value == EOF) return -1;
> >>  
> >> +		*curr = value;
> >>  		ret++;
> >>  		if (*curr == '\n' && hit == 1)
> >>  			return ret - 1;
> > 
> > 
> > 
> 
> 
> -- 
> ~Randy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
