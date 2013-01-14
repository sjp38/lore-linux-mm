Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id CB8946B006E
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 21:33:41 -0500 (EST)
Date: Mon, 14 Jan 2013 11:33:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/2] Enhance read_block of page_owner.c
Message-ID: <20130114023338.GB18097@blaptop>
References: <1357871401-7075-1-git-send-email-minchan@kernel.org>
 <1357871401-7075-2-git-send-email-minchan@kernel.org>
 <xa1t8v7zbteu.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <xa1t8v7zbteu.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Randy Dunlap <rdunlap@infradead.org>

On Fri, Jan 11, 2013 at 05:01:29PM +0100, Michal Nazarewicz wrote:
> It occurred to me -- and I know it will sound like a heresy -- that
> maybe providing an overly long example in C is not the best option here.
> Why not page_owner.py with the following content instead (not tested):
> 
> 
> #!/usr/bin/python
> import collections
> import sys
> 
> counts = collections.defaultdict(int)
> 
> txt = ''
> for line in sys.stdin:
>     if line == '\n':
>         counts[txt] += 1
>         txt = ''
>     else:
>         txt += line
> counts[txt] += 1
> 
> for txt, num in sorted(counts.items(), txt=lambda x: x[1]):
>     if len(txt) > 1:
>         print '%d times:\n%s' % num, txt
> 
> 
> And it's so a??longa?? only because I chose not to read the whole file at
> once as in:
> 
>     
> counts = collections.defaultdict(int)
> for txt in sys.stdin.read().split('\n\n'):
>     counts[txt] += 1

I'm not familar with Python but I can see the point of the program.
It's very short and good for maintainace but I have a concern about the size.
For working it in embedded side, we have to port python in that machine. :(
You might argue we can parse it on host after downloading from target machine.
But the problem is somecase we have no facility to download it from target
machine because only connection to outside is LCD.
In case of that, just small C program when we release product would be
good choice.

But I'm not strong aginst on your simple python program. If it is merged,
we will just continue to use C program instead of python's one.
If you have a strong opinion, send it to akpm as separate patch.

Thanks.

> 
> 
> On Fri, Jan 11 2013, Minchan Kim wrote:
> > The read_block reads char one by one until meeting two newline.
> > It's not good for the performance and current code isn't good shape
> > for readability.
> >
> > This patch enhances speed and clean up.
> >
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Andy Whitcroft <apw@shadowen.org>
> > Cc: Alexander Nyberg <alexn@dsv.su.se>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/page_owner.c |   34 +++++++++++++---------------------
> >  1 file changed, 13 insertions(+), 21 deletions(-)
> >
> > diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
> > index 43dde96..96bf481 100644
> > --- a/Documentation/page_owner.c
> > +++ b/Documentation/page_owner.c
> > @@ -28,26 +28,17 @@ static int max_size;
> >  
> >  struct block_list *block_head;
> >  
> > -int read_block(char *buf, FILE *fin)
> > +int read_block(char *buf, int buf_size, FILE *fin)
> >  {
> > -	int ret = 0;
> > -	int hit = 0;
> > -	int val;
> > -	char *curr = buf;
> > -
> > -	for (;;) {
> > -		val = getc(fin);
> > -		if (val == EOF) return -1;
> > -		*curr = val;
> > -		ret++;
> > -		if (*curr == '\n' && hit == 1)
> > -			return ret - 1;
> > -		else if (*curr == '\n')
> > -			hit = 1;
> > -		else
> > -			hit = 0;
> > -		curr++;
> > +	char *curr = buf, *const buf_end = buf + buf_size;
> > +
> > +	while (buf_end - curr > 1 && fgets(curr, buf_end - curr, fin)) {
> > +		if (*curr == '\n') /* empty line */
> > +			return curr - buf;
> > +		curr += strlen(curr);
> >  	}
> > +
> > +	return -1; /* EOF or no space left in buf. */
> >  }
> >  
> >  static int compare_txt(struct block_list *l1, struct block_list *l2)
> > @@ -84,10 +75,12 @@ static void add_list(char *buf, int len)
> >  	}
> >  }
> >  
> > +#define BUF_SIZE	1024
> > +
> >  int main(int argc, char **argv)
> >  {
> >  	FILE *fin, *fout;
> > -	char buf[1024];
> > +	char buf[BUF_SIZE];
> >  	int ret, i, count;
> >  	struct block_list *list2;
> >  	struct stat st;
> > @@ -106,11 +99,10 @@ int main(int argc, char **argv)
> >  	list = malloc(max_size * sizeof(*list));
> >  
> >  	for(;;) {
> > -		ret = read_block(buf, fin);
> > +		ret = read_block(buf, BUF_SIZE, fin);
> >  		if (ret < 0)
> >  			break;
> >  
> > -		buf[ret] = '\0';
> >  		add_list(buf, ret);
> >  	}
> >  
> > -- 
> > 1.7.9.5
> >
> 
> -- 
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
> ..o | Computer Science,  MichaA? a??mina86a?? Nazarewicz    (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--





-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
